// Medical Record Tab extracted from patient_medical_record_screen.dart
// All code is in English and self-contained for the Medical Record tab
// ... (code will be filled in next step) ... 

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'doctor_UploadScreen.dart';
import 'package:intl/intl.dart';

class MedicalRecordTab extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientId;
  final Map<String, String>? preFilledData;
  const MedicalRecordTab({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
    this.preFilledData,
  });
  @override
  State<MedicalRecordTab> createState() => _MedicalRecordTabState();
}

class _MedicalRecordTabState extends State<MedicalRecordTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoadingRecords = true;
  late final TextEditingController _conditionController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _notesController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _labTestsController;
  late final TextEditingController _radiologyTestsController;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
    _conditionController = TextEditingController();
    _symptomsController = TextEditingController();
    _notesController = TextEditingController();
    _medicationsController = TextEditingController();
    _labTestsController = TextEditingController();
    _radiologyTestsController = TextEditingController();
    if (widget.preFilledData != null) {
      _conditionController.text = widget.preFilledData!['medical_condition'] ?? '';
      _symptomsController.text = widget.preFilledData!['symptoms'] ?? '';
      _notesController.text = '';
      _medicationsController.text = widget.preFilledData!['medications'] ?? '';
      _labTestsController.text = widget.preFilledData!['tests'] ?? '';
      _radiologyTestsController.text = widget.preFilledData!['scans'] ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewMedicalRecordDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _medicationsController.dispose();
    _labTestsController.dispose();
    _radiologyTestsController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalRecords() async {
    try {
      setState(() {
        _isLoadingRecords = true;
      });
      final response = await _supabase
          .from('medical_records')
          .select('*, doctors!medical_records_doctor_id_fkey(name), lab_reports(report_id, Title, created_at, status), Radiology(Radiology_id, Title, created_at, status)')
          .eq('patient_id', widget.patientId)
          .order('created_at', ascending: false);
      setState(() {
        _medicalRecords = List<Map<String, dynamic>>.from(response);
        _isLoadingRecords = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medical records: [31m${e.toString()}[0m')),
        );
        setState(() {
          _isLoadingRecords = false;
        });
      }
    }
  }

  Widget _buildMedicalRecord() {
    if (_isLoadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }
    return _medicalRecords.isEmpty
        ? _buildEmptyMedicalRecord()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medicalRecords.length,
            itemBuilder: (context, index) =>
                _buildMedicalRecordCard(_medicalRecords[index], index),
          );
  }

  Widget _buildEmptyMedicalRecord() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined,
              size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 18),
          Text('No medical records found',
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            'Create a new medical record for ${widget.patientName}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showNewMedicalRecordDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record, int index) {
    final String date = record['created_at'] != null
        ? DateTime.parse(record['created_at'])
            .toLocal()
            .toString()
            .split(' ')[0]
        : 'N/A';
    final String symptoms = record['symptoms'] ?? 'N/A';
    final String notes = record['notes'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';
    final String doctorName = record['doctors']?['name'] ?? 'N/A';
    final String recordId = record['record_id']?.toString() ?? '';

    final List<Map<String, dynamic>> labReports = (record['lab_reports'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final List<Map<String, dynamic>> radiologyReports = (record['Radiology'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $date',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
              ),
              Text(
                'Doctor: $doctorName',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Symptoms',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_medicalRecords.length - index}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            symptoms,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Notes', notes),
          const SizedBox(height: 8),
          if (labReports.isNotEmpty) ...[
            Text(
              'Lab Tests',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: labReports.map((report) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  report['Title'] ?? 'N/A',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (radiologyReports.isNotEmpty) ...[
            Text(
              'Radiology Tests',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: radiologyReports.map((report) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  report['Title'] ?? 'N/A',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
          ],
          _buildInfoRow('Medications', medications),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditMedicalRecordDialog(context, record);
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  label: Text('Edit',
                      style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (recordId.isNotEmpty) {
                      _deleteMedicalRecord(recordId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot delete record: Invalid record ID')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Delete',
                      style: AppTheme.bodyLarge.copyWith(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }

  void _showNewMedicalRecordDialog(BuildContext context) {
    if (widget.preFilledData != null) {
      _conditionController.text = widget.preFilledData!['medical_condition'] ?? '';
      _symptomsController.text = widget.preFilledData!['symptoms'] ?? '';
      _notesController.text = '';
      _medicationsController.text = widget.preFilledData!['medications'] ?? '';
      _labTestsController.text = widget.preFilledData!['tests'] ?? '';
      _radiologyTestsController.text = widget.preFilledData!['scans'] ?? '';
    } else {
      _conditionController.text = '';
      _symptomsController.text = '';
      _notesController.text = '';
      _medicationsController.text = '';
      _labTestsController.text = '';
      _radiologyTestsController.text = '';
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Medical Record',
                style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Patient: ${widget.patientName}',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                'Age: ${widget.patientAge}',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _conditionController,
                decoration: themedInputDecoration(
                    label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomsController,
                decoration: themedInputDecoration(
                    label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: themedInputDecoration(
                    label: 'Notes (Doctor\'s Comments)', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _medicationsController,
                decoration: themedInputDecoration(
                    label: 'Medications', icon: Icons.medical_services_outlined),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labTestsController,
                decoration: themedInputDecoration(
                    label: 'Lab Tests', icon: Icons.science),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _radiologyTestsController,
                decoration: themedInputDecoration(
                    label: 'Radiology Tests', icon: Icons.medical_information),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final medicalCondition = _conditionController.text.trim();
                        final symptoms = _symptomsController.text.trim();
                        final notes = _notesController.text.trim();
                        final medications = _medicationsController.text.trim();
                        final labTests = _labTestsController.text.trim();
                        final radiologyTests = _radiologyTestsController.text.trim();
                        await _addManualMedicalRecord(
                          medicalCondition: medicalCondition,
                          symptoms: symptoms,
                          notes: notes,
                          medications: medications,
                          labTests: labTests,
                          radiologyTests: radiologyTests,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMedicalRecordDialog(
      BuildContext context, Map<String, dynamic> record) {
    _conditionController.text = record['medical_condition'] ?? '';
    _symptomsController.text = record['symptoms'] ?? '';
    _notesController.text = record['notes'] ?? '';
    _medicationsController.text = record['medications'] ?? '';
    _labTestsController.text = record['tests'] ?? '';
    _radiologyTestsController.text = record['scans'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Medical Record',
                style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Patient: ${widget.patientName}',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                'Age: ${widget.patientAge}',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _conditionController,
                decoration: themedInputDecoration(
                    label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomsController,
                decoration: themedInputDecoration(
                    label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration:
                    themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _medicationsController,
                decoration: themedInputDecoration(
                    label: 'Medications', icon: Icons.medical_services_outlined),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _labTestsController,
                decoration: themedInputDecoration(
                    label: 'Lab Tests', icon: Icons.science),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _radiologyTestsController,
                decoration: themedInputDecoration(
                    label: 'Radiology Tests', icon: Icons.medical_information),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final String updatedCondition =
                            _conditionController.text.trim();
                        final String updatedSymptoms =
                            _symptomsController.text.trim();
                        final String updatedNotes =
                            _notesController.text.trim();
                        final String updatedMedications =
                            _medicationsController.text.trim();
                        final String updatedLabTests =
                            _labTestsController.text.trim();
                        final String updatedRadiologyTests =
                            _radiologyTestsController.text.trim();
                        await _updateMedicalRecord(
                          record['record_id'],
                          updatedCondition,
                          updatedSymptoms,
                          updatedNotes,
                          updatedMedications,
                          updatedLabTests,
                          updatedRadiologyTests,
                        );
                        _conditionController.clear();
                        _symptomsController.clear();
                        _notesController.clear();
                        _medicationsController.clear();
                        _labTestsController.clear();
                        _radiologyTestsController.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: AppTheme.bodyLarge,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addManualMedicalRecord({
    required String medicalCondition,
    required String symptoms,
    required String notes,
    required String medications,
    required String labTests,
    required String radiologyTests,
  }) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }
      final doctorResponse = await _supabase
          .from('doctors')
          .select('doctor_id')
          .eq('user_id', currentUser.id)
          .maybeSingle();
      if (doctorResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Doctor profile not found. Cannot add medical record.')),
          );
        }
        return;
      }
      final doctorId = doctorResponse['doctor_id'];
      final newMedicalRecord = await _supabase.from('medical_records').insert({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'medical_condition': medicalCondition,
        'symptoms': symptoms,
        'notes': notes,
        'medications': medications,
      }).select('record_id').single(); // Get the record_id of the newly inserted medical record

      final String newRecordId = newMedicalRecord['record_id'].toString();

      // Insert into lab_reports if labTests is provided
      if (labTests.isNotEmpty) {
        await _supabase.from('lab_reports').insert({
          'medical_record_id': newRecordId,
          'patient_id': widget.patientId,
          'doctor_id': doctorId,
          'Title': labTests,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'Normal Results',
        });
      }

      // Insert into Radiology if radiologyTests is provided
      if (radiologyTests.isNotEmpty) {
        await _supabase.from('Radiology').insert({
          'medical_record_id': newRecordId,
          'patient_id': widget.patientId,
          'doctor_id': doctorId,
          'Title': radiologyTests,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'Normal Results',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Medical record added successfully!')));
      }
      _loadMedicalRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add medical record: [31m${e.toString()}[0m')),
        );
      }
    }
  }

  Future<void> _updateMedicalRecord(
    String recordId,
    String medicalCondition,
    String symptoms,
    String notes,
    String medications,
    String labTests,
    String radiologyTests,
  ) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }
      final doctorResponse = await _supabase
          .from('doctors')
          .select('doctor_id')
          .eq('user_id', currentUser.id)
          .maybeSingle();
      if (doctorResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Doctor profile not found. Cannot update medical record.')),
          );
        }
        return;
      }
      final doctorId = doctorResponse['doctor_id'];

      final response = await _supabase
          .from('medical_records')
          .update({
            'medical_condition': medicalCondition,
            'symptoms': symptoms,
            'notes': notes,
            'medications': medications,
          })
          .eq('record_id', recordId)
          .select();

      // Handle updates for lab_reports
      if (labTests.isNotEmpty) {
        // For simplicity, we'll always insert a new report on update if the field is not empty.
        // A more complex logic might involve checking for existing reports and updating them.
        await _supabase.from('lab_reports').insert({
          'medical_record_id': recordId,
          'patient_id': widget.patientId,
          'doctor_id': doctorId,
          'Title': labTests,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'Normal Results',
        });
      }

      // Handle updates for Radiology reports
      if (radiologyTests.isNotEmpty) {
        await _supabase.from('Radiology').insert({
          'medical_record_id': recordId,
          'patient_id': widget.patientId,
          'doctor_id': doctorId,
          'Title': radiologyTests,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'Normal Results',
        });
      }

      if (response.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to update medical record: Record not found or no changes made.')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Medical record updated successfully!')));
      }
      _loadMedicalRecords();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update medical record: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteMedicalRecord(String recordId) async {
    if (recordId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete record with empty ID.')),
        );
      }
      return;
    }
    try {
      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this medical record?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
      if (confirmDelete == true) {
        final response = await _supabase
            .from('medical_records')
            .delete()
            .eq('record_id', recordId);
        await _loadMedicalRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical record deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete medical record: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration themedInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      labelStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMedicalRecordDialog(context),
        label: Text('Add Medical Record', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _isLoadingRecords
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecords.isEmpty
              ? _buildEmptyMedicalRecord()
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
                  itemCount: _medicalRecords.length,
                  itemBuilder: (context, index) =>
                      _buildMedicalRecordCard(_medicalRecords[index], index),
                ),
    );
  }
} 