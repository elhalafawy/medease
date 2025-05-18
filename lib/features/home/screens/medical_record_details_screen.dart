import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  final String patientName;
  final String diagnosis;
  final String tests;
  final String medications;

  const MedicalRecordDetailsScreen({
    super.key,
    required this.patientName,
    required this.diagnosis,
    required this.tests,
    required this.medications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Medical Record Details',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.surface,
                  backgroundImage: const AssetImage('assets/images/profile_picture.png'),
                ),
              ),
            ),
            _buildRecordDetailItem(
              label: 'Patient Name:',
              value: patientName,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Diagnosis:',
              value: diagnosis,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Tests/Exams:',
              value: tests,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Medications:',
              value: medications,
              theme: theme,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Lab Results
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withAlpha(20),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: theme.colorScheme.primary, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science, color: theme.colorScheme.primary, size: 32),
                          const SizedBox(height: 8),
                          Text('Lab Results', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to X-Ray
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withAlpha(20),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: theme.colorScheme.primary, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.medical_information, color: theme.colorScheme.primary, size: 32),
                          const SizedBox(height: 8),
                          Text('X-Ray', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetailItem({required String label, required String value, required ThemeData theme}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
