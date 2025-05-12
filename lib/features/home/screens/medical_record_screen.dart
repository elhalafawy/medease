import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'medical_record_details_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'lab_reports_screen.dart';

class MedicalRecordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MedicalRecordScreen({super.key, this.onBack});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  String selectedTab = 'All Records';
  final List<Map<String, dynamic>> records = [
    {
      'patientName': 'Ahmed Elhalafwy',
      'diagnosis': 'Chronic Back Pain',
      'tests': 'X-ray, Blood Test',
      'medications': 'Amoxicillin, Ibuprofen',
      'date': DateTime(2025, 5, 10),
    },
    {
      'patientName': 'Sara Mostafa',
      'diagnosis': 'Diabetes',
      'tests': 'Blood Sugar',
      'medications': 'Metformin',
      'date': DateTime(2024, 11, 2),
    },
    {
      'patientName': 'Mohamed Ali',
      'diagnosis': 'Hypertension',
      'tests': 'Blood Pressure',
      'medications': 'Amlodipine',
      'date': DateTime(2025, 2, 18),
    },
  ];

  List<String> get yearsTabs {
    final years = records.map((r) => r['date'].year.toString()).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return ['All Records', ...years];
  }

  List<Map<String, dynamic>> get filteredRecords {
    if (selectedTab == 'All Records') return records;
    return records.where((r) => r['date'].year.toString() == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Medical Record',
          style: AppTheme.titleLarge,
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
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
            _buildLabReportsButton(context),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            ...filteredRecords.map((record) => _buildRecordItem(
              patientName: record['patientName'],
              diagnosis: record['diagnosis'],
              tests: record['tests'],
              medications: record['medications'],
              date: record['date'],
              context: context,
            )),
            if (filteredRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('No records found for this year.', style: AppTheme.bodyLarge),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabReportsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LabReportsScreen()),
          );
        },
        icon: const Icon(Icons.science, color: Colors.white),
        label: const Text('Lab & Radiology Reports'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTheme.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: yearsTabs.map((label) {
        final isSelected = label == selectedTab;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = label),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordItem({
    required String patientName,
    required String diagnosis,
    required String tests,
    required String medications,
    required DateTime date,
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
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.medical_services, color: AppTheme.primaryColor, size: 32),
                radius: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Diagnosis: $diagnosis',
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tests: $tests',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Medications: $medications',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Added on: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward, color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Show more',
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
