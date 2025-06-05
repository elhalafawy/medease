import 'package:flutter/material.dart';
import 'lab_reports_screen.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  final String patientName;
  final String symptoms;
  final String tests;
  final String medications;
  final String notes;
  final DateTime date;
  final String? profileImageUrl;

  const MedicalRecordDetailsScreen({
    super.key,
    required this.patientName,
    required this.symptoms,
    required this.tests,
    required this.medications,
    required this.notes,
    required this.date,
    this.profileImageUrl,
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
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!) as ImageProvider
                    : const AssetImage('assets/images/profile_picture.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              title: 'Patient Name',
              value: patientName,
              icon: Icons.person,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Symptoms',
              value: symptoms,
              icon: Icons.healing,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Notes',
              value: notes,
              icon: Icons.note_alt,
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
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LabReportsScreen(initialCategory: 0),
                          ),
                        );
                      },
                      icon: const Icon(Icons.science),
                      label: const Text('Lab Results'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                        textStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LabReportsScreen(initialCategory: 1),
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/icons/Radiology.png',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Radiology'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                        textStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
