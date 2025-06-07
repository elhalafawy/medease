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
      _labTestsController.text = widget.preFilledData!['lab_tests'] ?? '';
      _radiologyTestsController.text = widget.preFilledData!['radiology_tests'] ?? '';
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
          .select('*, doctors!medical_records_doctor_id_fkey(name)')
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
                _buildMedicalRecordCard(_medicalRecords[index]),
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

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final String date = record['created_at'] != null
        ? DateTime.parse(record['created_at'])
            .toLocal()
            .toString()
            .split(' ')[0]
        : 'N/A';
    final String symptoms = record['symptoms'] ?? 'N/A';
    final String notes = record['notes'] ?? 'N/A';
    final String tests = record['tests'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';
    final String doctorName = record['doctors']?['name'] ?? 'N/A';
    final String recordId = record['record_id']?.toString() ?? '';
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
          _buildInfoRow('Symptoms', symptoms),
          const SizedBox(height: 8),
          _buildInfoRow('Notes', notes),
          const SizedBox(height: 8),
          _buildInfoRow('Tests', tests),
          const SizedBox(height: 8),
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
      _labTestsController.text = widget.preFilledData!['lab_tests'] ?? '';
      _radiologyTestsController.text = widget.preFilledData!['radiology_tests'] ?? '';
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
                    label: 'Radiology Tests', icon: Icons.biotech),
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
                        String labTest1 = '';
                        String labTest2 = '';
                        if (labTests.isNotEmpty) {
                          final parts = labTests.split(RegExp(r'[\n,]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          if (parts.isNotEmpty) labTest1 = parts[0];
                          if (parts.length > 1) labTest2 = parts[1];
                        }
                        String radiologyTest1 = '';
                        String radiologyTest2 = '';
                        if (radiologyTests.isNotEmpty) {
                          final parts = radiologyTests.split(RegExp(r'[\n,]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          if (parts.isNotEmpty) radiologyTest1 = parts[0];
                          if (parts.length > 1) radiologyTest2 = parts[1];
                        }
                        await _addManualMedicalRecord(
                          medicalCondition: medicalCondition,
                          symptoms: symptoms,
                          notes: notes,
                          medications: medications,
                          labTest1: labTest1,
                          labTest2: labTest2,
                          radiologyTest1: radiologyTest1,
                          radiologyTest2: radiologyTest2,
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
    _labTestsController.text = record['lab_tests'] ?? '';
    _radiologyTestsController.text = record['radiology_tests'] ?? '';

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
                    label: 'Radiology Tests', icon: Icons.biotech),
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
    required String labTest1,
    required String labTest2,
    required String radiologyTest1,
    required String radiologyTest2,
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
      await _supabase.from('medical_records').insert({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'medical_condition': medicalCondition,
        'symptoms': symptoms,
        'notes': notes,
        'medications': medications,
        'lab_test1': labTest1,
        'lab_test2': labTest2,
        'radiology_test1': radiologyTest1,
        'radiology_test2': radiologyTest2,
      });
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
      String labTest1 = '';
      String labTest2 = '';
      if (labTests.isNotEmpty) {
        final parts = labTests.split(RegExp(r'[\n,]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        if (parts.isNotEmpty) labTest1 = parts[0];
        if (parts.length > 1) labTest2 = parts[1];
      }
      String radiologyTest1 = '';
      String radiologyTest2 = '';
      if (radiologyTests.isNotEmpty) {
        final parts = radiologyTests.split(RegExp(r'[\n,]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        if (parts.isNotEmpty) radiologyTest1 = parts[0];
        if (parts.length > 1) radiologyTest2 = parts[1];
      }
      final response = await _supabase
          .from('medical_records')
          .update({
            'medical_condition': medicalCondition,
            'symptoms': symptoms,
            'notes': notes,
            'medications': medications,
            'lab_test1': labTest1,
            'lab_test2': labTest2,
            'radiology_test1': radiologyTest1,
            'radiology_test2': radiologyTest2,
          })
          .eq('record_id', recordId)
          .select();
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
                      _buildMedicalRecordCard(_medicalRecords[index]),
                ),
    );
  }
} 