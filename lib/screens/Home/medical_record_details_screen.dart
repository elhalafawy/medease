import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text(
          'Medical Record Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  // Widget for displaying each item in the details
  Widget _buildRecordDetailItem({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  // Buttons for actions (Cancel, Reschedule, etc.)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Handle Cancel action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB4B4B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Cancel Appointment',
              style: TextStyle(fontWeight: FontWeight.w600),
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
              backgroundColor: const Color(0xFF022E5B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Reschedule Appointment',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
