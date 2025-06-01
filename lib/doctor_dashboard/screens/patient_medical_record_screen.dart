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
  bool _isLoadingRecords = true;
  bool _isLoadingLabReports = true; // Add loading state for lab reports

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

      setState(() {
        _labReports = List<Map<String, dynamic>>.from(response);
        _isLoadingLabReports = false;
      });
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
    try {
      await _supabase
          .from('medical_records')
          .delete()
          .eq('record_id', recordId); // Assuming 'record_id' is the primary key

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record deleted successfully!'))
        );
      }
      _loadMedicalRecords(); // Refresh the list after deleting
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete medical record: ${e.toString()}')),
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
      body: Column(
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
            child: KeyedSubtree(
              key: ValueKey(selectedTab),
              child: selectedTab == 0
                  ? _buildMedicalRecord()
                  : selectedTab == 1
                      ? _buildLabAndRadiology()
                      : _buildMedications(),
            ),
          ),
        ],
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
    final String medicalCondition = record['medical_condition'] ?? 'N/A';
    final String symptoms = record['symptoms'] ?? 'N/A';
    final String notes = record['notes'] ?? 'N/A';
    final String tests = record['tests'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';
    // Access doctor name from the nested object, providing default
    final String doctorName = record['doctors']?['name'] ?? 'N/A';

    // Assuming 'record_id' is the primary key of the medical_records table
    final String recordId = record['record_id'] ?? ''; // Handle potential null by providing empty string

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
              Expanded(
                child: Text(
                  date,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Dr. $doctorName', // Display doctor name
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          _buildRecordDetailRow('Medical Condition:', medicalCondition),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Symptoms:', symptoms),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Notes:', notes),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Tests:', tests),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Medications:', medications),
          const SizedBox(height: 20),
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
                     _deleteMedicalRecord(recordId); // Call delete function
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

  Widget _buildRecordDetailRow(String label, String value) {
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
    return _buildEmptyLabAndRadiology();

    // Original logic (commented out)
    // if (_isLoadingLabReports) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    //
    // if (_labReports.isEmpty) {
    //   return _buildEmptyLabAndRadiology();
    // }
    //
    // return ListView.builder(
    //   padding: const EdgeInsets.all(16),
    //   itemCount: _labReports.length,
    //   itemBuilder: (context, index) {
    //     final report = _labReports[index];
    //     // Map database columns to _buildReportCard expected format
    //     final String title = report['Title'] ?? 'N/A';
    //     final String date = report['created_at'] != null
    //         ? DateFormat('dd MMM, yyyy').format(DateTime.parse(report['created_at']).toLocal())
    //         : 'N/A';
    //     final String status = report['status'] ?? 'N/A';
    //
    //     // Determine status color based on status string
    //     Color statusColor = AppTheme.greyColor; // Default color
    //     if (status == 'Normal Results') {
    //       statusColor = Colors.green;
    //     } else if (status == 'Requires Attention') {
    //       statusColor = Colors.orange;
    //     } else if (status == 'Urgent') {
    //       statusColor = Colors.red;
    //     }
    //
    //     // Get doctor name from the joined table
    //     final String doctorName = report['doctors']?['name'] ?? 'N/A';
    //
    //     return _buildReportCard(
    //       'Lab Report',
    //       {
    //         'title': title,
    //         'date': date,
    //         'status': status,
    //         'statusColor': statusColor,
    //         'result': status, // Using status for result as per existing structure
    //         'desc': 'Report added by Dr. $doctorName', // Include doctor who added the report
    //       },
    //     );
    //   },
    // );
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
    return medications.isEmpty
        ? Center(
            child: Text('No medications found', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) => _buildMedicationCard(medications[index]),
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
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
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
          Text(medication['name'], style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor)),
          const SizedBox(height: 8),
          Text('Dosage: ${medication['dosage']}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text('Frequency: ${medication['frequency']}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text('Duration: ${medication['duration']}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Status: ', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              Text(medication['status'], style: AppTheme.bodyMedium.copyWith(color: medication['statusColor'], fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
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
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
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
        'Title': title,
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
                        final String medications = _medicationsController.text.trim();
                        final String tests = _testsController.text.trim();

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
} 