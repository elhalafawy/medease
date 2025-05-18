import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
           icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Terms & Conditions", style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. By using the MedEase app, you agree to use the platform only for lawful purposes related to medical consultation, appointment booking, or health tracking.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
              const SizedBox(height: 16),
              Text("2. You are responsible for maintaining the confidentiality of your login credentials and any personal health information you share.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
              const SizedBox(height: 16),
              Text("3. MedEase does not provide emergency medical care. For urgent cases, contact your local emergency service.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
              const SizedBox(height: 16),
              Text("4. We reserve the right to suspend or terminate your access to the app if any misuse is detected.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}
