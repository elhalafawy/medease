// Lab & Radiology Tab extracted from patient_medical_record_screen.dart
// All code is in English and self-contained for the Lab & Radiology tab
// ... (code will be filled in next step) ... 

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'lab_radiology_report_details_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LabRadiologyTab extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientId;

  const LabRadiologyTab({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
  });

  @override
  State<LabRadiologyTab> createState() => _LabRadiologyTabState();
}

class _LabRadiologyTabState extends State<LabRadiologyTab> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _labReports = [];
  List<Map<String, dynamic>> _radiologyReports = [];
  bool _isLoadingLabReports = true;
  bool _isLoadingRadiology = true;
  int selectedLabRadiologyTab = 0;
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoadingMedicalRecords = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadMedicalRecords();
    await _loadLabReports();
    await _loadRadiologyReports();
    _cleanupExistingUrls();
  }

  Future<void> _cleanupExistingUrls() async {
    try {
      // Clean up lab reports URLs
      for (var report in _labReports) {
        if (report['report_url'] != null) {
          final url = report['report_url'];
          if (url.startsWith('http')) {
            // Extract the file path from the URL
            final path = url.split('/').last;
            // Update the report URL in the database instead of trying to update the storage URL
            await _supabase
                .from('lab_reports')
                .update({'report_url': path})
                .eq('report_id', report['report_id']);
          }
        }
      }

      // Clean up radiology reports URLs
      for (var report in _radiologyReports) {
        if (report['report_url'] != null) {
          final url = report['report_url'];
          if (url.startsWith('http')) {
            // Extract the file path from the URL
            final path = url.split('/').last;
            // Update the report URL in the database instead of trying to update the storage URL
            await _supabase
                .from('Radiology')
                .update({'report_url': path})
                .eq('Radiology_id', report['Radiology_id']);
          }
        }
      }
    } catch (e) {
      print('Error cleaning up URLs: $e');
    }
  }

  Future<void> _pickAndUploadFile(Map<String, dynamic> report, bool isRadiology) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final String bucket = isRadiology ? 'radiology' : 'labreports';
      final String fileExt = file.path.split('.').last;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String filePath = '${widget.patientId}/$fileName';

      // Upload file to Supabase Storage
      final bytes = await file.readAsBytes();
      await _supabase.storage.from(bucket).uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          contentType: 'image/$fileExt',
          upsert: true,
        ),
      );

      // Get the public URL
      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);

      // Update the report in the database
      final String tableName = isRadiology ? 'Radiology' : 'lab_reports';
      final String idField = isRadiology ? 'Radiology_id' : 'report_id';
      final String reportId = report[idField]?.toString() ?? '';

      if (reportId.isNotEmpty) {
        await _supabase
            .from(tableName)
            .update({'report_url': filePath})
            .eq(idField, reportId);

        // Refresh the reports list
        if (isRadiology) {
          _loadRadiologyReports();
        } else {
          _loadLabReports();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File uploaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadLabReports() async {
    try {
      setState(() {
        _isLoadingLabReports = true;
      });
      final response = await _supabase
          .from('lab_reports')
          .select('*, doctors!lab_reports_doctor_id_fkey(name)')
          .eq('patient_id', widget.patientId)
          .order('created_at', ascending: false);
      setState(() {
        _labReports = List<Map<String, dynamic>>.from(response);
        _labReports = _labReports.map((report) {
          final medicalRecordId = report['medical_record_id'];
          final recordIndex = _medicalRecords.indexWhere((mr) => mr['record_id'] == medicalRecordId);
          if (recordIndex != -1) {
            report['sequential_record_number'] = _medicalRecords.length - recordIndex;
          }
          return report;
        }).toList();
        _isLoadingLabReports = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading lab reports: ${e.toString()}')),
        );
        setState(() {
          _isLoadingLabReports = false;
        });
      }
    }
  }

  Future<void> _loadRadiologyReports() async {
    try {
      setState(() {
        _isLoadingRadiology = true;
      });
      final response = await _supabase
          .from('Radiology')
          .select('*, doctors!Radiology_doctor_id_fkey(name)')
          .eq('patient_id', widget.patientId)
          .order('created_at', ascending: false);
      setState(() {
        _radiologyReports = List<Map<String, dynamic>>.from(response);
        _radiologyReports = _radiologyReports.map((report) {
          final medicalRecordId = report['medical_record_id'];
          final recordIndex = _medicalRecords.indexWhere((mr) => mr['record_id'] == medicalRecordId);
          if (recordIndex != -1) {
            report['sequential_record_number'] = _medicalRecords.length - recordIndex;
          }
          return report;
        }).toList();
        _isLoadingRadiology = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error loading radiology reports: ${e.toString()}')),
        );
        setState(() {
          _isLoadingRadiology = false;
        });
      }
    }
  }

  Future<void> _loadMedicalRecords() async {
    try {
      setState(() {
        _isLoadingMedicalRecords = true;
      });
      final response = await _supabase
          .from('medical_records')
          .select('record_id, record_number, created_at')
          .eq('patient_id', widget.patientId)
          .order('created_at', ascending: false);
      setState(() {
        _medicalRecords = List<Map<String, dynamic>>.from(response);
        _isLoadingMedicalRecords = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicalRecords = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLabRadiologyRecordDialog(
          context,
          isRadiology: selectedLabRadiologyTab == 1,
        ),
        label: Text(
          selectedLabRadiologyTab == 0 ? 'Add Lab Record' : 'Add Radiology Record',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
        icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _labRadiologySubTabButton('Lab Tests', 0)),
                const SizedBox(width: 8),
                Expanded(child: _labRadiologySubTabButton('Radiology', 1)),
              ],
            ),
          ),
          Expanded(
            child: selectedLabRadiologyTab == 0
                ? (_isLoadingLabReports
                    ? const Center(child: CircularProgressIndicator())
                    : _labReports.isEmpty
                        ? _buildEmptyLab()
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
                            itemCount: _labReports.length,
                            itemBuilder: (context, index) =>
                                _buildReportCard('Lab Report', _labReports[index]),
                          ))
                : (_isLoadingRadiology
                    ? const Center(child: CircularProgressIndicator())
                    : _radiologyReports.isEmpty
                        ? _buildEmptyRadiology()
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
                            itemCount: _radiologyReports.length,
                            itemBuilder: (context, index) => _buildReportCard(
                                'Radiology Report', _radiologyReports[index]),
                          )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLab() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 18),
          Text('No lab reports found',
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            'Create a new lab record for ${widget.patientName}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLabRadiologyRecordDialog(context),
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

  Widget _buildEmptyRadiology() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 18),
          Text('No radiology reports found',
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            'Create a new radiology record for ${widget.patientName}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddLabRadiologyRecordDialog(context,
                isRadiology: true),
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

  Widget _buildReportCard(String type, Map<String, dynamic> report) {
    final theme = Theme.of(context);
    final String title = report['Title'] ?? 'N/A';
    final String date = report['created_at'] != null
        ? DateFormat('dd MMM, yyyy').format(
            DateTime.parse(report['created_at'])
                .toLocal())
        : 'N/A';
    final String status = report['status'] ?? 'N/A';
    final Color statusColor = _getStatusColor(status);
    final String description = report['desc'] ?? '';
    final String reportUrl = report['report_url'] ?? '';
    final String recordId = report['report_id']?.toString() ?? report['Radiology_id']?.toString() ?? '';
    final bool isRadiology = type == 'Radiology Report';
    final String medicalRecordNumber = report['sequential_record_number']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.08), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1.2),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Medical Record #$medicalRecordNumber',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Date: $date',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LabRadiologyReportDetailsScreen(
                          reportData: report,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove_red_eye,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 4), // Spacing between icon and text
                      Text(
                        'View',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8), // Added space
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickAndUploadFile(report, isRadiology),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file, color: theme.colorScheme.primary),
                      const SizedBox(width: 4), // Spacing between icon and text
                      Text(
                        'Upload',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8), // Added space
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showEditLabRadiologyRecordDialog(context, report, isRadiology: isRadiology, recordId: recordId),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: theme.colorScheme.primary),
                      const SizedBox(width: 4), // Spacing between icon and text
                      Text(
                        'Edit',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8), // Added space
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (recordId.isNotEmpty) {
                      _deleteLabRadiologyRecord(recordId, isRadiology: isRadiology);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cannot delete record: Invalid record ID')),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 4), // Spacing between icon and text
                      Text(
                        'Delete',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal Results':
        return Colors.green;
      case 'Requires Attention':
        return Colors.orange;
      case 'Urgent':
        return Colors.red;
      default:
        return AppTheme.greyColor;
    }
  }

  void _showAddLabRadiologyRecordDialog(BuildContext context,
      {bool isRadiology = false}) {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    String? selectedStatus;
    String? selectedMedicalRecordId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9 - 16, // Adjusted width
              maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
            ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRadiology ? 'New Radiology Record' : 'New Lab Record',
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
                  _isLoadingMedicalRecords
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: themedInputDecoration(label: 'Medical Record', icon: Icons.folder),
                                value: selectedMedicalRecordId,
                                hint: const Text(
                                  'Select Medical Record',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMedicalRecordId = newValue;
                                  });
                                },
                                items: _medicalRecords.asMap().entries.map<DropdownMenuItem<String>>((entry) {
                                  final index = entry.key;
                                  final record = entry.value;
                                  final displayedRecordNumber = _medicalRecords.length - index;
                                  final date = record['created_at']?.toString().split('T').first ?? '';
                                  return DropdownMenuItem<String>(
                                    value: record['record_id'],
                                    child: Text(
                                      'Record #$displayedRecordNumber ($date)',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: themedInputDecoration(
                    label: isRadiology ? 'Radiology Title' : 'Report Title',
                    icon: isRadiology ? Icons.receipt_long_outlined : Icons.description_outlined,
                  ),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                  decoration: themedInputDecoration(
                      label: 'Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: themedInputDecoration(
                      label: 'Status', icon: Icons.info_outline),
                  value: selectedStatus,
                    hint: Text(
                      'Select Status',
                      style: AppTheme.bodyLarge
                          .copyWith(color: AppTheme.greyColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                  items: <Map<String, dynamic>>[
                    {'value': 'Normal Results', 'color': Colors.green},
                    {'value': 'Requires Attention', 'color': Colors.orange},
                    {'value': 'Urgent', 'color': Colors.red},
                  ].map<DropdownMenuItem<String>>((Map<String, dynamic> status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Text(
                        status['value'],
                        style:
                            AppTheme.bodyLarge.copyWith(color: status['color']),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                    );
                  }).toList(),
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
                        onPressed: () {
                          final String title = titleController.text.trim();
                          final DateTime? date = selectedDate;
                          final String? status = selectedStatus;
                            if (title.isNotEmpty && date != null && status != null && selectedMedicalRecordId != null) {
                            Navigator.of(context).pop();
                              _addLabRadiologyRecord(title, date, status, isRadiology, selectedMedicalRecordId!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill all fields')),
                            );
                          }
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
                        child: const Text('Save Record'),
                      ),
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addLabRadiologyRecord(
    String title, DateTime date, String status, bool isRadiology, String medicalRecordId) async {
    try {
      if (isRadiology) {
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
                      'Doctor profile not found. Cannot add radiology report.')),
            );
          }
          return;
        }
        final doctorId = doctorResponse['doctor_id'];
        await _supabase.from('Radiology').insert({
          'patient_id': widget.patientId,
          'doctor_id': doctorId,
          'Title': title,
          'status': status,
          'created_at': date.toIso8601String(),
          'medical_record_id': medicalRecordId,
        });

        // Update the associated medical record with the radiology test title
        final medicalRecord = await _supabase
            .from('medical_records')
            .select('radiology_tests')
            .eq('record_id', medicalRecordId)
            .single();

        String existingRadiologyTests = medicalRecord['radiology_tests'] ?? '';
        String updatedRadiologyTests = existingRadiologyTests.isEmpty
            ? title
            : '${existingRadiologyTests}, ${title}';

        await _supabase
            .from('medical_records')
            .update({'radiology_tests': updatedRadiologyTests})
            .eq('record_id', medicalRecordId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Radiology report added successfully!')));
        }
        _loadRadiologyReports();
        return;
      }
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
                content:
                    Text('Doctor profile not found. Cannot add lab report.')),
          );
        }
        return;
      }
      final doctorId = doctorResponse['doctor_id'];
      await _supabase.from('lab_reports').insert({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'Title': title,
        'status': status,
        'created_at': date.toIso8601String(),
        'medical_record_id': medicalRecordId,
      });

      // Update the associated medical record with the lab test title
      final medicalRecord = await _supabase
          .from('medical_records')
          .select('lab_tests')
          .eq('record_id', medicalRecordId)
          .single();

      String existingLabTests = medicalRecord['lab_tests'] ?? '';
      String updatedLabTests = existingLabTests.isEmpty
          ? title
          : '${existingLabTests}, ${title}';

      await _supabase
          .from('medical_records')
          .update({'lab_tests': updatedLabTests})
          .eq('record_id', medicalRecordId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lab report added successfully!')));
      }
      _loadLabReports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add lab report: ${e.toString()}')),
        );
      }
    }
  }

  void _showEditLabRadiologyRecordDialog(
      BuildContext context, Map<String, dynamic> record,
      {bool isRadiology = false, String? recordId}) {
    final TextEditingController titleController =
        TextEditingController(text: record['Title'] ?? '');
    DateTime? selectedDate = record['created_at'] != null
        ? DateTime.tryParse(record['created_at'])
        : null;
    String? selectedStatus = record['status'] ?? null;
    final String currentRecordId = recordId ??
        record['Radiology_id']?.toString() ??
        record['report_id']?.toString() ??
        '';
    final bool isRadiologyRecord =
        isRadiology || record.containsKey('Radiology_id');
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9 - 16, // Adjusted width
              maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
            ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRadiologyRecord ? 'Edit Radiology Record' : 'Edit Lab Record',
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
                  controller: titleController,
                  decoration: themedInputDecoration(
                      label: 'Report Title', icon: Icons.description_outlined),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                  decoration: themedInputDecoration(
                      label: 'Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: themedInputDecoration(
                      label: 'Status', icon: Icons.info_outline),
                  value: selectedStatus,
                    hint: Text(
                      'Select Status',
                      style: AppTheme.bodyLarge
                          .copyWith(color: AppTheme.greyColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                  items: <Map<String, dynamic>>[
                    {'value': 'Normal Results', 'color': Colors.green},
                    {'value': 'Requires Attention', 'color': Colors.orange},
                    {'value': 'Urgent', 'color': Colors.red},
                  ].map<DropdownMenuItem<String>>((Map<String, dynamic> status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Text(
                        status['value'],
                        style:
                            AppTheme.bodyLarge.copyWith(color: status['color']),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                      ),
                    );
                  }).toList(),
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
                          final String updatedTitle = titleController.text.trim();
                          final DateTime? updatedDate = selectedDate;
                          final String? updatedStatus = selectedStatus;
                          if (currentRecordId.isNotEmpty &&
                              updatedTitle.isNotEmpty &&
                              updatedDate != null &&
                              updatedStatus != null) {
                            await _updateLabRadiologyRecord(
                              currentRecordId,
                              updatedTitle,
                              updatedDate,
                              updatedStatus,
                              isRadiologyRecord,
                            );
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill all fields and ensure record has a valid ID')),
                            );
                          }
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
        ),
      ),
    );
  }

  Future<void> _updateLabRadiologyRecord(
    String recordId,
    String title,
    DateTime date,
    String status,
    bool isRadiology,
  ) async {
    try {
      final response = await _supabase
          .from(isRadiology ? 'Radiology' : 'lab_reports')
          .update({
            'Title': title,
            'created_at': date.toIso8601String(),
            'status': status,
          })
          .eq(isRadiology ? 'Radiology_id' : 'report_id', recordId)
          .select();
      if (response.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to update lab/radiology record: Record not found or no changes made.')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lab/Radiology record updated successfully!')));
      }
      if (isRadiology) {
        _loadRadiologyReports();
      } else {
        _loadLabReports();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update lab/radiology record: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteLabRadiologyRecord(String reportId,
      {bool isRadiology = false}) async {
    try {
      final bool isRadiologyRecord = _radiologyReports.any((r) =>
          r['Radiology_id']?.toString() == reportId);
      await _supabase
          .from(isRadiologyRecord ? 'Radiology' : 'lab_reports')
          .delete()
          .eq(isRadiologyRecord ? 'Radiology_id' : 'report_id', reportId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lab/Radiology record deleted successfully!')));
      }
      _loadLabReports();
      _loadRadiologyReports();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to delete lab/radiology record: ${e.toString()}')),
        );
      }
    }
  }

  InputDecoration themedInputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      isDense: true,
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

  Widget _labRadiologySubTabButton(String label, int index) {
    final bool selected = selectedLabRadiologyTab == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => selectedLabRadiologyTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
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