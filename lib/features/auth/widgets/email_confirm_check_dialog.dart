import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/supabase/auth_service.dart';
import '../../../core/providers/auth_provider.dart';

class EmailConfirmCheckDialog extends StatefulWidget {
  final String email;

  const EmailConfirmCheckDialog({super.key, required this.email});

  @override
  State<EmailConfirmCheckDialog> createState() => _EmailConfirmCheckDialogState();
}

class _EmailConfirmCheckDialogState extends State<EmailConfirmCheckDialog> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;
  bool _isResending = false;
  
  // Timer variables
  Timer? _timer;
  int _timeLeft = 60; // Timer duration in seconds (1 minute)
  bool _timerFinished = false;
  
  @override
  void initState() {
    super.initState();
    // Start timer when dialog opens
    _startTimer();
  }
  
  @override
  void dispose() {
    // Cancel timer when dialog closes
    _timer?.cancel();
    super.dispose();
  }
  
  // Function to start the timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timerFinished = true;
          timer.cancel();
          // Auto-check when timer expires
          _checkEmailVerification(isTimerFinished: true);
        }
      });
    });
  }
  
  String _maskEmail(String email) {
    var parts = email.split('@');
    if (parts.length != 2) return email;
    var name = parts[0];
    if (name.length <= 3) return email;
    var maskedName = '${name.substring(0, 3)}*****';
    return '$maskedName@${parts[1]}';
  }

  Future<void> _checkEmailVerification({bool isTimerFinished = false}) async {
    setState(() {
      _isChecking = true;
    });
    
    try {
      // استخدام الطريقة الجديدة التي تعتمد على الجدول
      final isVerified = await _authService.checkEmailVerificationFromTable();
      
      if (!mounted) return;
      
      if (isVerified) {
        await Provider.of<AuthProvider>(context, listen: false).refreshUserData();
        Navigator.of(context).pop();
        _showEmailVerifiedDialog();
      } else {
        if (isTimerFinished) {
          Navigator.of(context).pop();
          _showRegistrationFailedDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your inbox and spam folder.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in email verification check: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }
  
  // Function to resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });
    
    try {
      // Call function to resend verification link
      await _authService.resendVerificationEmail(widget.email);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification link resent. Please check your email.')),
      );
      
      // Reset timer
      setState(() {
        _timeLeft = 60;
        _timerFinished = false;
      });
      
      // Cancel old timer and start new one
      _timer?.cancel();
      _startTimer();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending verification link: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _showEmailVerifiedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 70,
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Verified Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00264D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your email has been verified. You can now use all features of the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to home page
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00264D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showRegistrationFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 70,
              ),
              const SizedBox(height: 20),
              const Text(
                'Registration Failed!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00264D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your email was not verified within the time limit. Please try again or check your email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Return to welcome screen using GoRouter
                  context.go('/welcome');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00264D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convert seconds to minutes:seconds format
    String minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    String timerText = '$minutes:$seconds';
    
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/letter.png', 
              height: 70,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.email, size: 70, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 16),
            // Display timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _timerFinished ? Colors.red.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Time Remaining: $timerText',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _timerFinished ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Verify Your Email',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification link to:\n${_maskEmail(widget.email)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your email and click the verification link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isChecking ? null : () => _checkEmailVerification(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00264D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'I\'ve Confirmed My Email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 12),
            // Resend verification link button
            TextButton.icon(
              onPressed: _isResending ? null : _resendVerificationEmail,
              icon: _isResending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text(
                'Resend Verification Link',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'I\'ll Do This Later',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show the email confirmation check dialog
Future<bool?> showEmailConfirmCheckDialog(BuildContext context, String email) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => EmailConfirmCheckDialog(email: email),
  );
}
