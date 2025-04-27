import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Terms & Conditions", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. By using the MedEase app, you agree to use the platform only for lawful purposes related to medical consultation, appointment booking, or health tracking.", style: TextStyle(fontSize: 16, height: 1.6)),
              SizedBox(height: 16),
              Text("2. You are responsible for maintaining the confidentiality of your login credentials and any personal health information you share.", style: TextStyle(fontSize: 16, height: 1.6)),
              SizedBox(height: 16),
              Text("3. MedEase does not provide emergency medical care. For urgent cases, contact your local emergency service.", style: TextStyle(fontSize: 16, height: 1.6)),
              SizedBox(height: 16),
              Text("4. We reserve the right to suspend or terminate your access to the app if any misuse is detected.", style: TextStyle(fontSize: 16, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}
