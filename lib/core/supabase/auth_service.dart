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
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final user = response.user;
      if (user == null) {
        return null;
      }
      // Get user role from users table
      final data = await _supabase.from('users').select('role').eq('id', user.id).single();
      return data['role'] as String?;
    } on AuthException catch (_) {
      return null;
    } catch (_) {
      return null;
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

  // Reset password for email
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Check if user's email is verified with force refresh
  Future<bool> isEmailVerified() async {
    try {
      // Force refresh session to get the most up-to-date status
      await _supabase.auth.refreshSession();

      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      print("Email verification status: ${user.emailConfirmedAt}");

      // Check if email is confirmed
      return user.emailConfirmedAt != null;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Update password for current user
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw AuthException('User not logged in');
    // Supabase doesn't support changing password with old password, only updating current user's password
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }


}
