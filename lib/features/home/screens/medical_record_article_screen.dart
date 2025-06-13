import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MedicalRecordArticleScreen extends StatelessWidget {
  const MedicalRecordArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Records Application',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Understanding Medical Records in MedEase',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/Medical_record.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Medical records are a vital component of modern healthcare, and MedEase is designed to help you manage them efficiently. They contain a comprehensive history of your health, including diagnoses, treatments, medications, test results, and doctor\'s notes.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.4),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            Text(
              'Benefits of Centralized Medical Records:',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Improved Patient Care',
              'Doctors can make more informed decisions with immediate access to your complete health history, leading to better diagnoses and personalized treatment plans.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Enhanced Safety',
              'Centralized records help prevent medication errors, adverse drug interactions, and duplicate tests, ensuring your safety.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Patient Empowerment',
              'Access to your own medical records allows you to be an active participant in your healthcare decisions and better understand your health journey.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Streamlined Communication',
              'Easy sharing of records among healthcare providers ensures seamless transitions of care and better coordination.',
            ),
            const SizedBox(height: 12),
            _buildBenefitPoint(
              theme,
              'Time and Cost Efficiency',
              'Reduces the need for repetitive tests and paperwork, saving both time and money.',
            ),
            const SizedBox(height: 20),
            Text(
              'MedEase offers a secure and user-friendly platform to store, access, and share your medical records. By leveraging technology, we aim to simplify healthcare management and empower you with control over your health information.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitPoint(ThemeData theme, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, height: 1.4),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 