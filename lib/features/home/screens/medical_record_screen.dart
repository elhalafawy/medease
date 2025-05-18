import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Medical Record',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
            _buildLabReportsButton(context, theme),
            const SizedBox(height: 16),
            _buildFilterTabs(theme),
            const SizedBox(height: 16),
            ...filteredRecords.map((record) => _buildRecordItem(
              patientName: record['patientName'],
              diagnosis: record['diagnosis'],
              tests: record['tests'],
              medications: record['medications'],
              date: record['date'],
              context: context,
              theme: theme,
            )),
            if (filteredRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('No records found for this year.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabReportsButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabReportsScreen()),
          );
        },
        icon: Icon(Icons.science, color: theme.colorScheme.onPrimary),
        label: Text('Lab & Radiology Reports', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
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
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
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
    required ThemeData theme,
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(20),
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
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                radius: 28,
                child: Icon(Icons.medical_services, color: theme.colorScheme.primary, size: 32),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patientName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Diagnosis: $diagnosis',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tests: $tests',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Medications: $medications',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Added on: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Show more',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
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
