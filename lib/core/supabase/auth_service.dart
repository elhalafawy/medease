import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Show error dialog
  Future<void> showErrorDialog(BuildContext context, String text) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("An error has occurred"),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  // Register with email and password with error handling
  Future<bool> registerWithEmailAndPasswordWithUI(BuildContext context, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password);
      if (response.user != null && (response.user!.emailConfirmedAt != null && response.user!.emailConfirmedAt!.isNotEmpty)) {
        // Supabase automatically sends verification email
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please verify your email.")),
      );
      return true;
    } on AuthException catch (e) {
      await showErrorDialog(context, e.message);
      return false;
    } catch (e) {
      await showErrorDialog(context, e.toString());
      return false;
    }
  }

  // Register patient with all required fields
  Future<bool> registerPatientWithEmailAndPassword(
    BuildContext context,
    String email,
    String password,
    String fullName,
    String dateOfBirth,
    String gender,
    String phone,
  ) async {
    try {
      // Sign up the user with Supabase auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Supabase will send a verification email automatically
      );

      final user = response.user;
      if (user == null) {
        await showErrorDialog(context, "Registration failed. No user returned.");
        return false;
      }

      // Add user to 'users' table
      await _supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'role': 'patient',
        'full_name': fullName,
        'phone': phone,
        'gender': gender,
        'password_hash': password,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      try {
        // Add patient to 'patients' table - using user_id consistently
        await _supabase.from('patients').insert({
          'user_id': user.id,  // Changed from 'id' to 'user_id' to be consistent
          'full_name': fullName,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'contact_info': phone,
        });
        print("Patient data added successfully to patients table");
      } catch (e) {
        // Log detailed error information for debugging
        print("PostgreSQL error adding patient data: $e");
        // Don't show error dialog as it might prevent the verification dialog
        // Just print to console for debugging
        return true; // Still return true since user was created
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful! Please check your email.")),
      );
      return true;
    } on AuthException catch (e) {
      await showErrorDialog(context, e.message);
      return false;
    } catch (e) {
      await showErrorDialog(context, e.toString());
      return false;
    }
  }

  // Login and return user role
  Future<String?> loginAndGetRole(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) {
        print('Login failed: No user returned');
        return null;
      }

      print('User logged in successfully. Checking email verification...');
      print('Email confirmed at: ${user.emailConfirmedAt}');

      // التحقق من تأكيد البريد الإلكتروني
      if (user.emailConfirmedAt == null) {
        print('Email not confirmed in auth session for user: ${user.id}');
        
        // التحقق من جدول التأكيد مباشرة
        try {
          final verificationStatus = await _supabase
              .from('email_verification_status')
              .select('is_verified')
              .eq('user_id', user.id)
              .maybeSingle();
              
          print('Verification status from table: $verificationStatus');
          
          final isVerified = verificationStatus != null && verificationStatus['is_verified'] == true;
          
          if (isVerified) {
            print('Email verified according to verification status table');
          } else {
            // التحقق من emailConfirmedAt مرة أخرى بعد تحديث الجلسة
            print('Refreshing session to check email confirmation again...');
            await _supabase.auth.refreshSession();
            final refreshedUser = _supabase.auth.currentUser;
            
            if (refreshedUser?.emailConfirmedAt != null) {
              print('Email confirmed after session refresh');
            } else {
              print('Email still not confirmed after session refresh');
              throw AuthException('Email not verified. Please check your email and click the confirmation link.');
            }
          }
        } catch (e) {
          if (e is AuthException) {
            throw e;
          }
          print('Error checking verification status: $e');
          throw AuthException('Error checking email verification: $e');
        }
      } else {
        print('Email already confirmed in auth session');
      }
      
      // Get user role from users table
      print('Getting user role...');
      final data = await _supabase.from('users').select('role').eq('id', user.id).single();
      final role = data['role'] as String?;
      print('User role: $role');
      return role;
    } on AuthException catch (e) {
      print('Auth exception during login: ${e.message}');
      throw e; // إعادة رمي الاستثناء للتعامل معه في واجهة المستخدم
    } catch (e) {
      print('General error during login: $e');
      throw AuthException('Login failed: $e');
    }
  }

  // Get full name by user id
  Future<String?> getFullNameByUserId(String userId) async {
    try {
      final data = await _supabase.from('users').select('full_name').eq('id', userId).single();
      return data['full_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // Google sign in for patients
  Future<bool> signInWithGoogleForPatient(BuildContext context) async {
    try {
      final res= await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      // After successful Google sign-in, add user data to tables if new
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      // Check if user already exists in users table
      final exists = await _supabase.from('users').select('id').eq('id', user.id).maybeSingle();
      if (exists == null) {
        // Skip password_hash issue by only handling patients table
        // Assume users table is automatically created by Supabase on sign-in
        try {
          // Add user directly to patients
          await _supabase.from('patients').insert({
            'user_id': user.id,
            'full_name': user.userMetadata?['name'] ?? '',
            'gender': user.userMetadata?['gender'] ?? '',
            'contact_info': '',
          });

          print('User successfully added to patients table');
        } catch (error) {
          print('Error adding user to patients: $error');
        }
      }
      return true;
    } catch (e) {
      await showErrorDialog(context, e.toString());
      return false;
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Delete current user account
  Future<bool> deleteCurrentUser(BuildContext context) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        await showErrorDialog(context, "No user is currently logged in.");
        return false;
      }

      final userId = currentUser.id;
      print('Starting user deletion process for user ID: $userId');

      // 1. Delete from email_verification_status table first
      try {
        print('Deleting from email_verification_status table...');
        await _supabase
            .from('email_verification_status')
            .delete()
            .eq('user_id', userId);
        print('Successfully deleted from email_verification_status');
      } catch (e) {
        print('Error deleting from email_verification_status: $e');
        // Continue with deletion even if this fails
      }

      // 2. Delete from patients table
      try {
        print('Deleting from patients table...');
        await _supabase
            .from('patients')
            .delete()
            .eq('user_id', userId);
        print('Successfully deleted from patients table');
      } catch (e) {
        print('Error deleting from patients table: $e');
        await showErrorDialog(context, "Error deleting patient data: $e");
        return false;
      }

      // 3. Delete from users table
      try {
        print('Deleting from users table...');
        await _supabase
            .from('users')
            .delete()
            .eq('id', userId);
        print('Successfully deleted from users table');
      } catch (e) {
        print('Error deleting from users table: $e');
        await showErrorDialog(context, "Error deleting user data: $e");
        return false;
      }

      // 4. Instead of using admin API, use stored procedure for user deletion
      try {
        print('Calling delete_user function...');
        await _supabase.rpc('delete_user', params: {'user_id': userId});
        print('User deletion RPC call completed');
      } catch (e) {
        print('Error in delete_user RPC: $e');
        await showErrorDialog(context, "Error during account deletion: $e");
        return false;
      }

      // 5. Finally sign out
      await signOut();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your account has been successfully deleted.")),
      );
      return true;
    } catch (e) {
      print('Error in delete user process: $e');
      await showErrorDialog(context, "Failed to delete user: $e");
      return false;
    }
  }

  // Reset password for email
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Error resending verification email: $e');
      rethrow;
    }
  }

  // Update password for current user
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw AuthException('User not logged in');
    
    try {
      // 1. First update password in auth system
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      
      // 2. Then update password_hash in public.users table
      await _supabase
          .from('users')
          .update({
            'password_hash': newPassword, // Note: In production, consider hashing this
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
          
    } on PostgrestException catch (e) {
      print('Error updating password_hash in users table: ${e.message}');
      throw AuthException('Failed to update password. Please try again.');
    } catch (e) {
      print('Unexpected error updating password: $e');
      rethrow;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      print('Checking email verification status...');
      
      // First try - complete session refresh
      final session = _supabase.auth.currentSession;
      if (session != null) {
        try {
          await _supabase.auth.refreshSession();
          print('Session refreshed successfully');
        } catch (e) {
          print('Error refreshing session: $e');
        }
      } else {
        print('No current session found');
      }
      
      var currentUser = _supabase.auth.currentUser;
      print('ATTEMPT 1 - Email confirmed at: ${currentUser?.emailConfirmedAt}');
      
      // If already confirmed, return immediately
      if (currentUser?.emailConfirmedAt != null) {
        print('Email confirmed on first check');
        return true;
      }
      
      // Multiple retry attempts with increasing delays
      final retryDelays = [3, 5, 8]; // seconds
      
      for (int i = 0; i < retryDelays.length; i++) {
        print('Email not confirmed, waiting ${retryDelays[i]} seconds and retrying (attempt ${i+2})...');
        await Future.delayed(Duration(seconds: retryDelays[i]));
        
        // Try refreshing session again
        try {
          await _supabase.auth.refreshSession();
          // For a more aggressive refresh, could try this:
          // await signInWithPassword(email: currentUser!.email!, password: '...'); 
          // But we don't have password here
        } catch (e) {
          print('Error in retry session refresh: $e');
        }
        
        // Check again
        currentUser = _supabase.auth.currentUser;
        print('ATTEMPT ${i+2} - Email confirmed at: ${currentUser?.emailConfirmedAt}');
        
        if (currentUser?.emailConfirmedAt != null) {
          print('Email confirmed on retry attempt ${i+2}');
          return true;
        }
      }
      
      // Final check
      return currentUser?.emailConfirmedAt != null;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }
  
  // Force refresh verification status with a thorough approach
  Future<bool> checkEmailVerificationDirectly() async {
    try {
      print('Starting advanced email verification check');
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser == null) {
        print('No current user found for verification check');
        return false;
      }
      
      print('Current email confirmation status: ${currentUser.emailConfirmedAt != null ? 'VERIFIED' : 'NOT VERIFIED'}');
      
      if (currentUser.emailConfirmedAt != null) {
        print('User email already verified in current session');
        return true;
      }
      
      print('Attempting session refresh...');
      try {
        await _supabase.auth.refreshSession();
        print('Session refreshed successfully');
        
        // Check if email is verified after refresh
        final refreshedUser = _supabase.auth.currentUser;
        if (refreshedUser?.emailConfirmedAt != null) {
          print('Email verified after session refresh');
          return true;
        }
      } catch (e) {
        print('Session refresh error: $e');
      }
      
      print('Attempting multiple refreshes with delays...');
      final retryDelays = [2, 4, 6];
      
      for (int i = 0; i < retryDelays.length; i++) {
        print('Retry ${i+1}: Waiting ${retryDelays[i]} seconds...');
        await Future.delayed(Duration(seconds: retryDelays[i]));
        
        try {
          await _supabase.auth.refreshSession();
          final retriedUser = _supabase.auth.currentUser;
          print('Retry ${i+1} verification status: ${retriedUser?.emailConfirmedAt != null ? 'VERIFIED' : 'NOT VERIFIED'}');
          
          if (retriedUser?.emailConfirmedAt != null) {
            print('Email verified on retry ${i+1}');
            return true;
          }
        } catch (e) {
          print('Retry ${i+1} refresh error: $e');
        }
      }
      
      // Final check after all attempts
      final finalUser = _supabase.auth.currentUser;
      final isVerified = finalUser?.emailConfirmedAt != null;
      print('Final verification status: ${isVerified ? 'VERIFIED' : 'NOT VERIFIED'}');
      return isVerified;
    } catch (e) {
      print('Error in verification process: $e');
      return false;
    }
  }
  
  Future<bool> checkEmailVerificationFromTable() async {
    try {
      print('Starting email verification check from table');
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        print('No current user found for verification check');
        return false;
      }
      
      print('Querying email_verification_status table for user ${currentUser.id}');
      final response = await _supabase
        .from('email_verification_status')
        .select('is_verified, verified_at')
        .eq('user_id', currentUser.id)
        .maybeSingle();
      
      print('Response from table query: $response');
      
      final isVerified = response != null && response['is_verified'] == true;
      print('Verification status from table: ${isVerified ? 'VERIFIED' : 'NOT VERIFIED'}');
      
      if (!isVerified) {
        // محاولة إضافية بتحديث الجلسة
        print('Table check failed, trying session refresh as fallback');
        await _supabase.auth.refreshSession();
        
        // محاولة ثانية للتحقق من الجدول
        final retryResponse = await _supabase
          .from('email_verification_status')
          .select('is_verified')
          .eq('user_id', currentUser.id)
          .maybeSingle();
        
        print('Retry response from table: $retryResponse');
        
        final retryVerified = retryResponse != null && retryResponse['is_verified'] == true;
        print('Retry verification status: ${retryVerified ? 'VERIFIED' : 'NOT VERIFIED'}');
        
        if (retryVerified) return true;
        
        // فحص مباشر للـ emailConfirmedAt
        final refreshedUser = _supabase.auth.currentUser;
        if (refreshedUser?.emailConfirmedAt != null) {
          print('User verified in session but not in table yet');
          return true;
        }
      }
      
      return isVerified;
    } catch (e) {
      print('Error checking verification from table: $e');
      // الرجوع للطريقة القديمة في حالة حدوث خطأ
      return await checkEmailVerificationDirectly();
    }
  }

  // Resend email verification link
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      print('Error resending verification email: $e');
      rethrow;
    }
  }
}
