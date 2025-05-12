import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Text(
            '''
MedEase respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data.

We may collect your name, email, phone number, and health-related information to enhance your experience within the app. This information is used to provide medical services, schedule appointments, and improve our platform.

We do not share your personal data with third parties without your consent, except when required by law.

All communications and medical records are encrypted and securely stored.

By using MedEase, you agree to this privacy policy. We may update this policy periodically, and all updates will be reflected in the app.
''',
            style: TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ),
    );
  }
}
