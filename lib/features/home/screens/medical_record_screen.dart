import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'medical_record_details_screen.dart';

class MedicalRecordScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const MedicalRecordScreen({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Record',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALL MEDICAL RECORDS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Filtered by year
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildRecordItem(
              patientName: 'ِAhmed Elhalafwy',
              diagnosis: 'Chronic Back Pain',
              tests: 'X-ray, Blood Test',
              medications: 'Amoxicillin, Ibuprofen',
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _FilterTab(label: 'All Records'),
        _FilterTab(label: '2025'),
        _FilterTab(label: '2024'),
      ],
    );
  }

  Widget _buildRecordItem({
    required String patientName,
    required String diagnosis,
    required String tests,
    required String medications,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
         Navigator.push(
           context, 
          MaterialPageRoute(
            builder: (context) => MedicalRecordDetailsScreen(
          patientName: patientName,
          diagnosis: diagnosis,
          tests: tests,
          medications: medications,
        ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_alarm_outlined,
                  color: Color(0xFF022E5B),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Patient: $patientName',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Diagnosis: $diagnosis',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF022E5B)),
            ),
            const SizedBox(height: 10),
            Text(
              'Tests: $tests',
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 10),
            Text(
              'Medications: $medications',
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Show more details
              },
              child: const Text(
                'Show more',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF022E5B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;

  const _FilterTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Filter logic
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
