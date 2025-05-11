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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Medical Record Details',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
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
            const Text(
              'Record Details',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Patient Name:',
              value: patientName,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Diagnosis:',
              value: diagnosis,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Tests/Exams:',
              value: tests,
            ),
            const SizedBox(height: 16),
            _buildRecordDetailItem(
              label: 'Medications:',
              value: medications,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordDetailItem({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodyLarge,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Cancel action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel Appointment',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Reschedule action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Reschedule Appointment',
              style: AppTheme.bodyLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
