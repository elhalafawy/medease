import 'package:flutter/material.dart';
import '../../../core/supabase/auth_service.dart';

class EmailConfirmCheckDialog extends StatefulWidget {
  final String email;

  const EmailConfirmCheckDialog({super.key, required this.email});

  @override
  State<EmailConfirmCheckDialog> createState() => _EmailConfirmCheckDialogState();
}

class _EmailConfirmCheckDialogState extends State<EmailConfirmCheckDialog> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;
  
  String _maskEmail(String email) {
    var parts = email.split('@');
    if (parts.length != 2) return email;
    var name = parts[0];
    if (name.length <= 3) return email;
    var maskedName = '${name.substring(0, 3)}*****';
    return '$maskedName@${parts[1]}';
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      // Force refresh to get latest status
      bool isVerified = await _authService.isEmailVerified();
      
      if (!mounted) return;
      
      if (isVerified) {
        // Email is verified, show success dialog
        Navigator.of(context).pop();
        _showEmailVerifiedDialog();
      } else {
        // Email is not verified yet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is not verified yet. Please check your inbox and spam folder.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking verification: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
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

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 24),
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
              onPressed: _isChecking ? null : _checkEmailVerification,
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
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'I\'ll do this later',
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
