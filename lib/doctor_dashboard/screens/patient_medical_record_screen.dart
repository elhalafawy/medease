import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'doctor_UploadScreen.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PatientMedicalRecordScreen extends StatefulWidget {
  final String patientName;
  final String patientAge;
  final String patientId;

  const PatientMedicalRecordScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientId,
  });

  @override
  State<PatientMedicalRecordScreen> createState() => _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState extends State<PatientMedicalRecordScreen> {
  int selectedTab = 0; // 0: Medical Record, 1: Lab & Radiology, 2: Medications
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _medicalRecords = [];
  List<Map<String, dynamic>> _labReports = []; // Add list for lab reports
  List<Map<String, dynamic>> _medicationsList = []; // Add list for medications
  bool _isLoadingRecords = true;
  bool _isLoadingLabReports = true; // Add loading state for lab reports
  bool _isLoadingMedications = true; // Add loading state for medications

  // Controllers for manual medical record entry
  late final TextEditingController _conditionController;
  late final TextEditingController _symptomsController;
  late final TextEditingController _notesController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _testsController;

  final List<Map<String, dynamic>> labReports = [
    {
      'title': 'Complete Blood Count (CBC)',
      'date': '02 Jan, 2024',
      'status': 'Normal Results',
      'result': 'Normal Results',
      'desc': '',
      'statusColor': const Color(0xFF1A7C3E),
    },
    {
      'title': 'Lipid Panel',
      'date': '02 Jan, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': const Color(0xFFFFA800),
    },
  ];

  final List<Map<String, dynamic>> radiologyReports = [
    {
      'title': 'Chest X-Ray',
      'date': '10 Feb, 2024',
      'status': 'Normal',
      'result': 'Normal',
      'desc': '',
      'statusColor': const Color(0xFF1A7C3E),
    },
    {
      'title': 'Abdominal Ultrasound',
      'date': '15 Feb, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': const Color(0xFFFFA800),
    },
  ];

  final List<Map<String, dynamic>> medications = [
    {
      'name': 'Amoxicillin',
      'dosage': '500mg',
      'frequency': '3 times daily',
      'duration': '7 days',
      'status': 'Active',
      'statusColor': const Color(0xFF1A7C3E),
    },
    {
      'name': 'Ibuprofen',
      'dosage': '400mg',
      'frequency': 'As needed',
      'duration': '5 days',
      'status': 'Active',
      'statusColor': const Color(0xFF1A7C3E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
    _loadLabReports(); // Load lab reports on init
    _loadMedications(); // Load medications on init
    // Initialize controllers
    _conditionController = TextEditingController();
    _symptomsController = TextEditingController();
    _notesController = TextEditingController();
    _medicationsController = TextEditingController();
    _testsController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers
    _conditionController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _medicationsController.dispose();
    _testsController.dispose();
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
          SnackBar(content: Text('Error loading medical records: ${e.toString()}')),
        );
        setState(() {
          _isLoadingRecords = false;
        });
      }
    }
  }

  Future<void> _loadLabReports() async {
    try {
      setState(() {
        _isLoadingLabReports = true;
      });
      print('Attempting to load lab reports for patient ID: ${widget.patientId}'); // Log start
      final response = await _supabase
          .from('lab_reports')
          .select('report_id, patient_id, doctor_id, status, created_at, Title, doctors!lab_reports_doctor_id_fkey(name)') // Select columns and join for doctor name
          .eq('patient_id', widget.patientId)
          .order('created_at', ascending: false);

      print('Supabase lab reports response: ${response.length} records found.'); // Log success
      print('Supabase lab reports fetched data (first 5 records): ${response.take(5).toList()}'); // Log fetched data

      setState(() {
        _labReports = List<Map<String, dynamic>>.from(response);
        _isLoadingLabReports = false;
      });
      print('setState called after loading lab reports. isLoadingLabReports: $_isLoadingLabReports'); // Log setState call

    } catch (e) {
      print('Error in _loadLabReports: ${e.toString()}'); // Log error
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

  Future<void> _loadMedications() async {
    try {
      setState(() {
        _isLoadingMedications = true;
      });
      print('Attempting to load medications for patient ID: ${widget.patientId}'); // Log start
      final response = await _supabase
          .from('medications') // Assuming your medications table is named 'medications'
          .select('*') // Select all columns, including medication_id if it exists
          .eq('patient_id', widget.patientId)
          .neq('status', 'cancelled') // Add filter to exclude cancelled medications
          .order('created_at', ascending: false); // Assuming a 'created_at' column for ordering

      print('Supabase medications response: ${response.length} records found.'); // Log success
      print('Supabase medications fetched data (first 5 records): ${response.take(5).toList()}'); // Log fetched data

      setState(() {
        _medicationsList = List<Map<String, dynamic>>.from(response);
        _isLoadingMedications = false;
      });
      print('setState called after loading medications. isLoadingMedications: $_isLoadingMedications'); // Log setState call

    } catch (e) {
      print('Error in _loadMedications: ${e.toString()}'); // Log error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medications: ${e.toString()}')),
        );
        setState(() {
          _isLoadingMedications = false;
        });
      }
    }
  }

  Future<void> _addManualMedicalRecord({
    required String medicalCondition,
    required String symptoms,
    required String notes,
    required String tests,
    required String medications,
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

      // Fetch the doctor's ID from the doctors table using the user's ID
      final doctorResponse = await _supabase
          .from('doctors')
          .select('doctor_id')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (doctorResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor profile not found. Cannot add medical record.')),
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
        'tests': tests,
        'medications': medications,
      });

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Medical record added successfully!'))
         );
      }
      _loadMedicalRecords(); // Refresh the list after adding
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add medical record: ${e.toString()}')),
        );
      }
    }
  }

   // Function to update a medical record in Supabase
  Future<void> _updateMedicalRecord(
    String recordId,
    String medicalCondition,
    String symptoms,
    String notes,
    String medications,
    String tests,
  ) async {
    try {
      // Add logging to check the data being sent
      print('Attempting to update record with ID: $recordId');
      print('Data: {medical_condition: $medicalCondition, symptoms: $symptoms, notes: $notes, medications: $medications, tests: $tests}');

      final response = await _supabase
          .from('medical_records')
          .update({
            'medical_condition': medicalCondition,
            'symptoms': symptoms,
            'notes': notes,
            'medications': medications,
            'tests': tests,
          })
          .eq('record_id', recordId) // Assuming 'record_id' is the primary key
          .select(); // Select the updated row to check the response

      // Add logging for the Supabase response
      print('Supabase update response: ${response}');

      if (response.isEmpty) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to update medical record: Record not found or no changes made.')),
           );
         }
         return; // Exit if no record was updated
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record updated successfully!'))
        );
      }
      _loadMedicalRecords(); // Refresh the list after updating
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medical record: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteMedicalRecord(String recordId) async {
    print('[_deleteMedicalRecord] Called with recordId: $recordId'); // Added logging
    if (recordId.isEmpty) {
      print('[_deleteMedicalRecord] recordId is empty. Aborting delete.'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete record with empty ID.')),
        );
      }
      return;
    }

    try {
      // Show a confirmation dialog
      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this medical record?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Return true on confirm
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      print('[_deleteMedicalRecord] Dialog result: $confirmDelete'); // Added logging

      // If user confirmed deletion
      if (confirmDelete == true) {
        print('[_deleteMedicalRecord] User confirmed deletion.'); // Added logging
        final response = await _supabase
            .from('medical_records')
            .delete()
            .eq('record_id', recordId);

        print('[_deleteMedicalRecord] Supabase delete response: $response'); // Added logging

        // Refresh the list after deletion
        await _loadMedicalRecords();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medical record deleted successfully')),
          );
        }
      } else {
        print('[_deleteMedicalRecord] User cancelled deletion.'); // Added logging
      }
    } catch (e) {
      print('[_deleteMedicalRecord] Error: ${e.toString()}'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting medical record: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Medical Records', style: theme.textTheme.titleLarge),
      ),
      body: GestureDetector(
        onTap: () {
          print('[ScaffoldBody] Tapped'); // Added logging for scaffold body tap
        },
        child: Column(
          children: [
            _buildTabs(),
            if (selectedTab == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showNewMedicalRecordDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print('[ExpandedListArea] Tapped'); // Added logging
                },
                child: KeyedSubtree(
                  key: ValueKey(selectedTab),
                  child: selectedTab == 0
                      ? _buildMedicalRecord()
                      : selectedTab == 1
                          ? _buildLabAndRadiology()
                          : _buildMedications(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
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

  Widget _buildMedicalRecord() {
    if (_isLoadingRecords) {
      return const Center(child: CircularProgressIndicator());
    }
    return _medicalRecords.isEmpty
        ? _buildEmptyMedicalRecord()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medicalRecords.length,
            itemBuilder: (context, index) => _buildMedicalRecordCard(_medicalRecords[index]),
          );
  }

  Widget _buildEmptyMedicalRecord() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 18),
          Text('No medical records found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            'Create a new medical record for ${widget.patientName}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
     // Safely access data from columns
    final String date = record['created_at'] != null 
      ? DateTime.parse(record['created_at']).toLocal().toString().split(' ')[0] // Format date
      : 'N/A';
    
    final String symptoms = record['symptoms'] ?? 'N/A';
    final String notes = record['notes'] ?? 'N/A';
    final String tests = record['tests'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';
    // Access doctor name from the nested object, providing default
    final String doctorName = record['doctors']?['name'] ?? 'N/A';

    // Get the record ID and log it
    final String recordId = record['record_id']?.toString() ?? '';
    print('Building medical record card with ID: $recordId'); // Added logging

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
                    _showEditMedicalRecordDialog(context, record); // Call edit dialog function
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  label: Text('Edit', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    print('Delete button pressed for record ID: $recordId'); // Added logging
                    if (recordId.isNotEmpty) {
                      _deleteMedicalRecord(recordId); // Call delete function with record ID
                    } else {
                      print('Record ID is empty, cannot delete'); // Added logging
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot delete record: Invalid record ID')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Delete', style: AppTheme.bodyLarge.copyWith(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  // --- Lab & Radiology Tab ---
  Widget _buildLabAndRadiology() {
    final theme = Theme.of(context);

    // Temporarily always show the empty state for debugging
    // return _buildEmptyLabAndRadiology();

    // Original logic (commented out)
    if (_isLoadingLabReports) {
      return const Center(child: CircularProgressIndicator());
    }

    // Keep the empty state widget, but remove the button from it
    final emptyState = _buildEmptyLabAndRadiology();

    return Column(
      children: [
         Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddLabRadiologyRecordDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
        Expanded(
          child: _labReports.isEmpty
              ? emptyState
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _labReports.length,
                  itemBuilder: (context, index) {
                    final report = _labReports[index];
                    // Map database columns to _buildReportCard expected format
                    final String title = report['Title'] ?? 'N/A';
                    final String date = report['created_at'] != null
                        ? DateFormat('dd MMM, yyyy').format(DateTime.parse(report['created_at']).toLocal())
                        : 'N/A';
                    final String status = report['status'] ?? 'N/A';

                    // Determine status color based on status string
                    Color statusColor = AppTheme.greyColor; // Default color
                    if (status == 'Normal Results') {
                      statusColor = Colors.green;
                    } else if (status == 'Requires Attention') {
                      statusColor = Colors.orange;
                    } else if (status == 'Urgent') {
                      statusColor = Colors.red;
                    }

                    // Get doctor name from the joined table
                    final String doctorName = report['doctors']?['name'] ?? 'N/A';

                    // Assuming 'report_id' is the primary key for lab_reports
                    final String reportId = report['report_id'] ?? ''; // Handle potential null by providing empty string
                    print('[LabReportCard] Report ID: $reportId'); // Added logging

                    // Add logging to show the full report data before building the card
                    print('[buildLabAndRadiology] Building Report Card for: $report');

                    return _buildReportCard(
                      'Lab Report', // Assuming all are lab reports for now, might need adjustment for radiology
                      {
                        'title': title,
                        'date': date,
                        'status': status,
                        'statusColor': statusColor,
                        'result': status, // Using status for result as per existing structure
                        'desc': 'Report added by Dr. $doctorName',
                        'report_id': reportId, // Ensure report_id is passed to _buildReportCard
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyLabAndRadiology() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 18),
          Text('No lab or radiology reports found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Text(
            'Create a new lab or radiology record for ${widget.patientName}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
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

  // --- Medications Tab ---
  Widget _buildMedications() {
    // Implementation for Medications tab
    if (_isLoadingMedications) {
      return const Center(child: CircularProgressIndicator());
    }
    return _medicationsList.isEmpty
        ? Center(
            child: Text('No medications found', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _medicationsList.length,
            itemBuilder: (context, index) => _buildMedicationCard(_medicationsList[index]), // Use loaded data
          );
  }

  Widget _buildReportCard(String type, Map<String, dynamic> report) {
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
          Text(report['title'], style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Text('Date: ${report['date']}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Status: ', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              Text(report['status'], style: AppTheme.bodyMedium.copyWith(color: report['statusColor'], fontWeight: FontWeight.bold)),
            ],
          ),
          if (report['desc'] != null && report['desc']!.isNotEmpty) ...[ // Added null check here
            const SizedBox(height: 8),
            Text('Details: ${report['desc']}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     // TODO: Implement edit functionality for Lab/Radiology records
                     _showEditLabRadiologyRecordDialog(context, report); // Call edit dialog function
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  label: Text('Edit', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     // TODO: Implement delete functionality for Lab/Radiology records
                     // Assuming 'report_id' is the primary key for lab_reports
                     final String reportId = report['report_id'] ?? '';
                     if (reportId.isNotEmpty) {
                        _deleteLabRadiologyRecord(reportId);
                     }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Delete', style: AppTheme.bodyLarge.copyWith(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    // Safely access data from columns
    final String medicationName = medication['name'] ?? 'N/A';
    final String dosage = medication['dosage'] ?? 'N/A';
    final String frequency = medication['frequency'] ?? 'N/A';
    // Access start and end dates
    final String? startDateString = medication['start_date'];
    final String? endDateString = medication['end_date'];

    String durationText = 'N/A';
    if (startDateString != null && endDateString != null) {
      try {
        final DateTime startDate = DateTime.parse(startDateString);
        final DateTime endDate = DateTime.parse(endDateString);
        final Duration duration = endDate.difference(startDate);
        // Format the duration (e.g., in days)
        durationText = '${duration.inDays + 1} days'; // Add 1 to include both start and end days
      } catch (e) {
        print('Error parsing dates for medication duration: ${e.toString()}');
        durationText = 'Invalid date format';
      }
    }

    // Assuming 'status' and 'statusColor' are columns in your medications table
    final String status = medication['status'] ?? 'N/A';
    // Determine status color based on status string (example, adjust as needed)
    Color statusColor = AppTheme.greyColor; // Default color
    if (status == 'Active') {
      statusColor = Colors.green;
    } else if (status == 'Completed') {
      statusColor = AppTheme.greyColor; // Or another color
    } // Add more status color logic if needed

    // Assuming 'medication_id' is the primary key of the medications table
    final String medicationId = medication['medication_id'] ?? ''; // Handle potential null

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
          Text(medicationName, style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Text('Dosage: ${dosage}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text('Frequency: ${frequency}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          // Display the calculated duration
          Text('Duration: ${durationText}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Status: ', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              Text(status, style: AppTheme.bodyMedium.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20), // Add spacing for buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit functionality for Medications
                    // _showEditMedicationDialog(context, medication);
                     print('[MedicationCard] Edit button pressed for: ${medication['medication_id']}'); // Added logging
                     _showEditMedicationDialog(context, medication); // Call edit dialog
                  },
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  label: Text('Edit', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     final String medicationId = medication['medication_id']?.toString() ?? '';
                     print('[MedicationCard] Delete button pressed for ID: $medicationId'); // Added logging
                     if (medicationId.isNotEmpty) {
                        _deleteMedication(medicationId); // Call delete function
                     } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Cannot delete medication: Invalid medication ID.')),
                         );
                         print('[MedicationCard] Cannot delete: medicationId is empty.'); // Added logging
                     }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text('Delete', style: AppTheme.bodyLarge.copyWith(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  // Function to delete a Medication from Supabase
  Future<void> _deleteMedication(String medicationId) async {
    print('[_deleteMedication] Called with medicationId: $medicationId'); // Added logging
    if (medicationId.isEmpty) {
      print('[_deleteMedication] medicationId is empty. Aborting delete.'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete medication: Invalid medication ID.')),
        );
      }
      return;
    }

    try {
      // Show a confirmation dialog
      final bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this medication record?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Return false on cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Return true on confirm
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      print('[_deleteMedication] Dialog result: $confirmDelete'); // Added logging

      // If user confirmed deletion
      if (confirmDelete == true) {
        print('[_deleteMedication] User confirmed deletion.'); // Added logging
        final response = await _supabase
            .from('medications')
            .delete()
            .eq('medication_id', medicationId);

        // Supabase delete operations typically return a status or an empty list on success
        // You might want to check for errors based on the Supabase client's response handling
        print('[_deleteMedication] Supabase delete response: $response'); // Added logging

        // Check if the delete was successful (Supabase might not throw an error on no rows deleted)
         if (response == null || response.isEmpty) { // Assuming response is null or empty on successful delete
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Medication record deleted successfully')),
             );
           }
            print('[_deleteMedication] Delete successful.'); // Added logging
         } else { // This case might indicate an error depending on Supabase client
            if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Failed to delete medication record: ${response.toString()}')),
             );
           }
           print('[_deleteMedication] Delete failed. Response: ${response}'); // Added logging
         }

        // Refresh the list after deletion
        await _loadMedications();

      } else {
        print('[_deleteMedication] User cancelled deletion.'); // Added logging
      }
    } catch (e) {
      print('[_deleteMedication] Error: ${e.toString()}'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting medication record: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddRecordChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Medical Record'),
        content: const Text('How would you like to add the medical record?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showNewMedicalRecordDialog(context);
            },
            child: const Text('Manual Entry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorUploadscreen(
                    // إذا كان الكونستركتور يقبل اسم المريض مرره هنا
                    // patientName: widget.patientName,
                  ),
                ),
              );
            },
            child: const Text('Upload Prescription (OCR)'),
          ),
        ],
      ),
    );
  }

  // --- Lab & Radiology Dialog ---
  void _showAddLabRadiologyRecordDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Lab / Radiology Record',
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                // Patient Name and Age
                Text(
                  'Patient: ${widget.patientName}',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Age: ${widget.patientAge}',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
                const SizedBox(height: 20),
                // Title Field
                TextField(
                  controller: titleController,
                  decoration: themedInputDecoration(label: 'Report Title', icon: Icons.description_outlined),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Date Picker Input
                TextFormField(
                  readOnly: true, // Prevent keyboard from appearing
                  controller: TextEditingController( // Use a temporary controller for display
                      text: selectedDate == null
                          ? '' // Empty string when no date is selected
                          : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                  decoration: themedInputDecoration(label: 'Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(), // Block dates before today
                      lastDate: DateTime(2101), // Allow selecting dates up to the year 2100
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        print('Selected date: $selectedDate'); // Keep for debugging
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  decoration: themedInputDecoration(label: 'Status', icon: Icons.info_outline),
                  value: selectedStatus,
                  hint: Text('Select Status', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
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
                        style: AppTheme.bodyLarge.copyWith(color: status['color']),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Buttons
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

                          if (title.isNotEmpty && date != null && status != null) {
                            Navigator.of(context).pop(); // Close the dialog
                            _addLabRadiologyRecord(title, date, status); // Call the save function
                          } else {
                            // Show validation error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields')),
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
    );
  }

  // Implement the actual database saving function for Lab/Radiology records
  Future<void> _addLabRadiologyRecord(String title, DateTime date, String status) async {
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

      // Fetch the doctor's ID from the doctors table using the user's ID
      final doctorResponse = await _supabase
          .from('doctors')
          .select('doctor_id') // Assuming doctor_id is the primary key
          .eq('user_id', currentUser.id) // Assuming user_id links to auth.users
          .maybeSingle();

      if (doctorResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor profile not found. Cannot add lab report.')),
          );
        }
        return;
      }

      final doctorId = doctorResponse['doctor_id'];

      await _supabase.from('lab_reports').insert({
        'patient_id': widget.patientId,
        'doctor_id': doctorId,
        'Title': title, // Use 'Title' as per _loadLabReports
        'status': status,
        'created_at': date.toIso8601String(), // Save date as ISO 8601 string
      });

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Lab report added successfully!'))
         );
      }
      _loadLabReports(); // Refresh the list after adding
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add lab report: ${e.toString()}')),
        );
      }
    }
  }

  // Function to delete a Lab/Radiology record from Supabase
  Future<void> _deleteLabRadiologyRecord(String reportId) async {
    try {
      await _supabase
          .from('lab_reports')
          .delete()
          .eq('report_id', reportId); // Assuming 'report_id' is the primary key

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab/Radiology record deleted successfully!'))
        );
      }
      _loadLabReports(); // Refresh the list after deleting
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete lab/radiology record: ${e.toString()}')),
        );
      }
    }
  }

  // Function to show the edit Lab/Radiology record dialog
  void _showEditLabRadiologyRecordDialog(BuildContext context, Map<String, dynamic> record) {
    final TextEditingController titleController = TextEditingController(text: record['Title'] ?? '');
    DateTime? selectedDate = record['created_at'] != null ? DateTime.tryParse(record['created_at']) : null;
    String? selectedStatus = record['status'] ?? null;

    // Add logging to show initial data
    print('[EditLabRadiologyDialog] Initial record data: $record');
    print('[EditLabRadiologyDialog] Initial title: ${titleController.text}');
    print('[EditLabRadiologyDialog] Initial date: $selectedDate');
    print('[EditLabRadiologyDialog] Initial status: $selectedStatus');

    // Correctly get the report_id from the record map
    final String reportId = record['report_id']?.toString() ?? '';
    print('[EditLabRadiologyDialog] Record ID from record: $reportId'); // Added logging

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Lab / Radiology Record',
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                // Patient Name and Age
                Text(
                  'Patient: ${widget.patientName}',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Age: ${widget.patientAge}',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
                const SizedBox(height: 20),
                // Title Field
                TextField(
                  controller: titleController,
                  decoration: themedInputDecoration(label: 'Report Title', icon: Icons.description_outlined),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Date Picker Input
                TextFormField(
                  readOnly: true, // Prevent keyboard from appearing
                  controller: TextEditingController(
                      text: selectedDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(selectedDate!)),
                  decoration: themedInputDecoration(label: 'Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101), // Allow selecting dates up to the year 2100
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                        print('[EditLabRadiologyDialog] Date selected: $selectedDate'); // Added logging
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  decoration: themedInputDecoration(label: 'Status', icon: Icons.info_outline),
                  value: selectedStatus,
                  hint: Text('Select Status', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                       print('[EditLabRadiologyDialog] Status selected: $selectedStatus'); // Added logging
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
                        style: AppTheme.bodyLarge.copyWith(color: status['color']),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Buttons
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
                          // Use the reportId captured when the dialog was opened

                          // Add logging to show data before update call
                          print('[EditLabRadiologyDialog] Save button pressed.');
                          print('[EditLabRadiiologyDialog] updatedTitle: $updatedTitle');
                          print('[EditLabRadiologyDialog] updatedDate: $updatedDate');
                          print('[EditLabRadiologyDialog] updatedStatus: $updatedStatus');
                          print('[EditLabRadiologyDialog] reportId: $reportId');

                          if (reportId.isNotEmpty && updatedTitle.isNotEmpty && updatedDate != null && updatedStatus != null) {
                            await _updateLabRadiologyRecord(
                              reportId,
                              updatedTitle,
                              updatedDate,
                              updatedStatus,
                            );
                            Navigator.of(context).pop(); // Close the dialog
                          } else {
                            // Show validation error or handle missing reportId
                            print('[EditLabRadiologyDialog] Validation failed.'); // Added logging
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields and ensure record has a valid ID')),
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
    );
  }

  // Function to update a Lab/Radiology record in Supabase
  Future<void> _updateLabRadiologyRecord(
    String reportId,
    String title,
    DateTime date,
    String status,
  ) async {
    try {
      // Add logging to check the data being sent
      print('[_updateLabRadiologyRecord] Attempting to update lab/radiology record with ID: $reportId');
      print('[_updateLabRadiologyRecord] Data: {Title: $title, created_at: ${date.toIso8601String()}, status: $status}');

      final response = await _supabase
          .from('lab_reports')
          .update({
            'Title': title,
            'created_at': date.toIso8601String(),
            'status': status,
          })
          .eq('report_id', reportId) // Assuming 'report_id' is the primary key
          .select(); // Select the updated row to check the response

      // Add logging for the Supabase response
      print('[_updateLabRadiologyRecord] Supabase update response: ${response}');

      if (response.isEmpty) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to update lab/radiology record: Record not found or no changes made.')),
           );
         }
         print('[_updateLabRadiologyRecord] Update failed: response is empty.'); // Added logging
         return; // Exit if no record was updated
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab/Radiology record updated successfully!'))
        );
      }
      print('[_updateLabRadiologyRecord] Update successful. Loading reports...'); // Added logging
      _loadLabReports(); // Refresh the list after updating
    } catch (e) {
      print('[_updateLabRadiologyRecord] Error: ${e.toString()}'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update lab/radiology record: ${e.toString()}')),
        );
      }
    }
  }

  void _showNewMedicalRecordDialog(BuildContext context) {
    // Use state-managed controllers
    _conditionController.clear(); // Clear previous text
    _symptomsController.clear();
    _notesController.clear();
    _medicationsController.clear();
    _testsController.clear();

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
                decoration: themedInputDecoration(label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomsController,
                decoration: themedInputDecoration(label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _medicationsController,
                decoration: themedInputDecoration(label: 'Medications', icon: Icons.medical_services),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _testsController,
                decoration: themedInputDecoration(label: 'Tests', icon: Icons.science),
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
                        // Collect data from controllers
                        final String medicalCondition = _conditionController.text.trim();
                        final String symptoms = _symptomsController.text.trim();
                        final String notes = _notesController.text.trim();
                        final String tests = _testsController.text.trim();
                        final String medications = _medicationsController.text.trim();

                        // Add the record to the database using new columns
                        await _addManualMedicalRecord(
                          medicalCondition: medicalCondition,
                          symptoms: symptoms,
                          notes: notes,
                          tests: tests,
                          medications: medications,
                        );

                        // Clear controllers after saving
                        _conditionController.clear();
                        _symptomsController.clear();
                        _notesController.clear();
                        _medicationsController.clear();
                        _testsController.clear();
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

  // Function to show the edit medical record dialog
  void _showEditMedicalRecordDialog(BuildContext context, Map<String, dynamic> record) {
    print('[EditDialog] Function called'); // Added logging
    // Populate controllers with existing record data
    _conditionController.text = record['medical_condition'] ?? '';
    _symptomsController.text = record['symptoms'] ?? '';
    _notesController.text = record['notes'] ?? '';
    _medicationsController.text = record['medications'] ?? '';
    _testsController.text = record['tests'] ?? '';

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
                decoration: themedInputDecoration(label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _symptomsController,
                decoration: themedInputDecoration(label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _medicationsController,
                decoration: themedInputDecoration(label: 'Medications', icon: Icons.medical_services),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _testsController,
                decoration: themedInputDecoration(label: 'Tests', icon: Icons.science),
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
                        // Collect updated data from controllers
                        final String updatedCondition = _conditionController.text.trim();
                        final String updatedSymptoms = _symptomsController.text.trim();
                        final String updatedNotes = _notesController.text.trim();
                        final String updatedMedications = _medicationsController.text.trim();
                        final String updatedTests = _testsController.text.trim();

                        // Update the record in the database
                        await _updateMedicalRecord(
                          record['record_id'], // Assuming 'record_id' is the primary key
                          updatedCondition,
                          updatedSymptoms,
                          updatedNotes,
                          updatedMedications,
                          updatedTests,
                        );

                        // Clear controllers after saving
                        _conditionController.clear();
                        _symptomsController.clear();
                        _notesController.clear();
                        _medicationsController.clear();
                        _testsController.clear();
                        Navigator.pop(context); // Close the dialog
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

  // Add a themed input decoration helper if it doesn't exist
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

  // Function to show the edit Medication dialog
  void _showEditMedicationDialog(BuildContext context, Map<String, dynamic> medication) {
    final TextEditingController nameController = TextEditingController(text: medication['name'] ?? '');
    final TextEditingController dosageController = TextEditingController(text: medication['dosage'] ?? '');
    final TextEditingController frequencyController = TextEditingController(text: medication['frequency'] ?? '');
    final TextEditingController notesController = TextEditingController(text: medication['notes'] ?? '');

    DateTime? selectedStartDate = medication['start_date'] != null ? DateTime.tryParse(medication['start_date']) : null;
    DateTime? selectedEndDate = medication['end_date'] != null ? DateTime.tryParse(medication['end_date']) : null;
    
    // Get the status value from the medication record and log it
    String? selectedStatus = medication['status'] ?? null;
    print('[EditMedicationDialog] Status from record: ${medication['status']}'); // Added logging
    print('[EditMedicationDialog] Initializing selectedStatus with: $selectedStatus'); // Added logging

    final String medicationId = medication['medication_id']?.toString() ?? '';

    print('[EditMedicationDialog] Initial medication data: $medication'); // Added logging
    print('[EditMedicationDialog] Initial medicationId: $medicationId'); // Added logging

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Medication',
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                // Patient Name and Age (Display only)
                 Text(
                  'Patient: ${widget.patientName}',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Age: ${widget.patientAge}',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
                const SizedBox(height: 20),
                // Medication Name Field
                TextField(
                  controller: nameController,
                  decoration: themedInputDecoration(label: 'Medication Name', icon: Icons.medical_services_outlined),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Dosage Field
                TextField(
                  controller: dosageController,
                  decoration: themedInputDecoration(label: 'Dosage', icon: Icons.medical_services),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Frequency Field
                TextField(
                  controller: frequencyController,
                  decoration: themedInputDecoration(label: 'Frequency', icon: Icons.repeat),
                  style: AppTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Start Date Picker Input
                 TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: selectedStartDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(selectedStartDate!)),
                  decoration: themedInputDecoration(label: 'Start Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000), // Allow past dates for start date
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedStartDate) {
                      setState(() {
                        selectedStartDate = picked;
                        print('[EditMedicationDialog] Start Date selected: $selectedStartDate'); // Added logging
                      });
                    }
                  },
                ),
                 const SizedBox(height: 16),
                // End Date Picker Input
                 TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: selectedEndDate == null
                          ? ''
                          : DateFormat('yyyy-MM-dd').format(selectedEndDate!)),
                  decoration: themedInputDecoration(label: 'End Date', icon: Icons.calendar_today_outlined),
                  style: AppTheme.bodyLarge,
                   onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate ?? DateTime.now(),
                      firstDate: selectedStartDate ?? DateTime.now(), // End date cannot be before start date
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedEndDate) {
                      setState(() {
                        selectedEndDate = picked;
                         print('[EditMedicationDialog] End Date selected: $selectedEndDate'); // Added logging
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Notes Field
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                  style: AppTheme.bodyLarge,
                ),
                 const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  decoration: themedInputDecoration(label: 'Status', icon: Icons.info_outline),
                  value: selectedStatus,
                  hint: Text('Select Status', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue;
                      print('[EditMedicationDialog] Status selected: $selectedStatus'); // Added logging
                    });
                  },
                   items: <String>['active', 'completed', 'canceled'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()), // Assuming you have a capitalize extension or function
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Buttons
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
                          final String updatedName = nameController.text.trim();
                          final String updatedDosage = dosageController.text.trim();
                          final String updatedFrequency = frequencyController.text.trim();
                          final String updatedNotes = notesController.text.trim();
                          final DateTime? updatedStartDate = selectedStartDate;
                          final DateTime? updatedEndDate = selectedEndDate;
                          final String? updatedStatus = selectedStatus;

                          // Add logging to show data before update call
                          print('[EditMedicationDialog] Save button pressed.');
                          print('[EditMedicationDialog] medicationId: $medicationId');
                          print('[EditMedicationDialog] updatedName: $updatedName');
                          print('[EditMedicationDialog] updatedDosage: $updatedDosage');
                          print('[EditMedicationDialog] updatedFrequency: $updatedFrequency');
                          print('[EditMedicationDialog] updatedStartDate: $updatedStartDate');
                          print('[EditMedicationDialog] updatedEndDate: $updatedEndDate');
                           print('[EditMedicationDialog] updatedStatus: $updatedStatus');

                          if (medicationId.isNotEmpty && updatedName.isNotEmpty && updatedDosage.isNotEmpty && updatedFrequency.isNotEmpty && updatedStartDate != null && updatedEndDate != null && updatedStatus != null) {
                            await _updateMedication(
                              medicationId,
                              updatedName,
                              updatedDosage,
                              updatedFrequency,
                              updatedStartDate,
                              updatedEndDate,
                              updatedNotes,
                              updatedStatus,
                            );
                            Navigator.of(context).pop(); // Close the dialog
                          } else {
                            // Show validation error
                            print('[EditMedicationDialog] Validation failed.'); // Added logging
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields and ensure medication has a valid ID')),
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
    );
  }

  // Function to update a Medication record in Supabase
  Future<void> _updateMedication(
    String medicationId,
    String name,
    String dosage,
    String frequency,
    DateTime startDate,
    DateTime endDate,
    String? notes,
    String status,
  ) async {
    try {
      // Add logging to check the data being sent
      print('[_updateMedication] Attempting to update medication with ID: $medicationId');
      print('[_updateMedication] Data: {name: $name, dosage: $dosage, frequency: $frequency, start_date: ${startDate.toIso8601String()}, end_date: ${endDate.toIso8601String()}, notes: $notes, status: $status}');

      final response = await _supabase
          .from('medications')
          .update({
            'name': name,
            'dosage': dosage,
            'frequency': frequency,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'notes': notes,
            'status': status,
             'updated_at': DateTime.now().toIso8601String(), // Update updated_at timestamp
          })
          .eq('medication_id', medicationId)
          .select(); // Select the updated row to check the response

      // Add logging for the Supabase response
      print('[_updateMedication] Supabase update response: ${response}');

      if (response.isEmpty) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to update medication record: Record not found or no changes made.')),
           );
         }
         print('[_updateMedication] Update failed: response is empty.'); // Added logging
         return; // Exit if no record was updated
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication record updated successfully!'))
        );
      }
      print('[_updateMedication] Update successful. Loading medications...'); // Added logging
      _loadMedications(); // Refresh the list after updating
    } catch (e) {
      print('[_updateMedication] Error: ${e.toString()}'); // Added logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update medication record: ${e.toString()}')),
        );
      }
    }
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
} 