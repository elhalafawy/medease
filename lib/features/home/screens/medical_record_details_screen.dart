import 'package:flutter/material.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  final String patientName;
  final String diagnosis;
  final String tests;
  final String medications;
  final DateTime date;

  const MedicalRecordDetailsScreen({
    super.key,
    required this.patientName,
    required this.diagnosis,
    required this.tests,
    required this.medications,
    required this.date,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Patient Name',
              value: patientName,
              icon: Icons.person,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Diagnosis',
              value: diagnosis,
              icon: Icons.medical_services,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Tests',
              value: tests,
              icon: Icons.science,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Medications',
              value: medications,
              icon: Icons.medication,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Date',
              value: '${date.day}/${date.month}/${date.year}',
              icon: Icons.calendar_today,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
