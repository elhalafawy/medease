import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginSuccessWidget extends StatefulWidget {
  const LoginSuccessWidget({super.key});

  @override
  State<LoginSuccessWidget> createState() => _LoginSuccessWidgetState();
}

class _LoginSuccessWidgetState extends State<LoginSuccessWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { 
        Navigator.pop(context); 
        context.go('/home'); 
      }
    });
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
              'assets/images/password_success.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Login Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00264D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome back! You have successfully logged in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                context.go('/home'); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00264D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
