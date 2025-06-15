import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'medical_record_tab.dart';
import 'lab_radiology_tab.dart';
import 'medications_tab.dart';

class PatientMedicalRecordScreen extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientId;
  final String? appointmentId;
  final Map<String, String>? preFilledData;

  const PatientMedicalRecordScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
    this.appointmentId,
    this.preFilledData,
  });

  @override
  State<PatientMedicalRecordScreen> createState() =>
      _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState
    extends State<PatientMedicalRecordScreen> {
  int selectedTab = 0; // 0: Medical Record, 1: Lab & Radiology, 2: Medications

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget currentTabWidget;

    switch (selectedTab) {
      case 0:
        currentTabWidget = MedicalRecordTab(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientId: widget.patientId,
          preFilledData: widget.preFilledData,
        );
        break;
      case 1:
        currentTabWidget = LabRadiologyTab(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientId: widget.patientId,
        );
        break;
      case 2:
        currentTabWidget = MedicationsTab(
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientId: widget.patientId,
        );
        break;
      default:
        currentTabWidget = const Center(child: Text('Select a tab.'));
        }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Medical Record - ${widget.patientName}', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Column(
          children: [
            _buildTabs(),
            Expanded(
            child: currentTabWidget,
            ),
          ],
      ),
    );
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _tabButton('Medical Record', 0)),
          const SizedBox(width: 8),
          Expanded(child: _tabButton('Lab & Radiology', 1)),
          const SizedBox(width: 8),
          Expanded(child: _tabButton('Medications', 2)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final bool selected = selectedTab == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
