import 'package:flutter/material.dart';

class VerificationSuccessDialog extends StatelessWidget {
  final String email;

  const VerificationSuccessDialog({super.key, required this.email});

  String _maskEmail(String email) {
    var parts = email.split('@');
    if (parts.length != 2) return email;
    var name = parts[0];
    if (name.length <= 3) return email;
    var maskedName = '${name.substring(0, 3)}*****';
    return '$maskedName@${parts[1]}';
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
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, size: 70, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Created Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00264D)),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification link to:\n${_maskEmail(email)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please check your email to verify your account.\nYou can continue using the app in the meantime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00264D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Continue to Home', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
