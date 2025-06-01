import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'doctor_UploadScreen.dart';

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
  bool _isLoadingRecords = true;

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
          .select()
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

  Future<void> _addManualMedicalRecord({
    required String diagnoses,
    required String prescription,
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
        'diagnosis': diagnoses,
        'prescription': prescription,
        'tests': tests,
        'medications': medications,
      });

      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Medical record added successfully!')),
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
                  onPressed: () => _showAddRecordChoiceDialog(context),
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
            child: selectedTab == 0
                ? _buildMedicalRecord()
                : selectedTab == 1
                    ? _buildLabAndRadiology()
                    : _buildMedications(),
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
            itemBuilder: (context, index) => _buildMedicalRecordCard(_medicalRecords[index], index),
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
            onPressed: () => _showAddRecordChoiceDialog(context),
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
     // Safely access data, providing default values or handling nulls
    final String date = record['created_at'] != null 
      ? DateTime.parse(record['created_at']).toLocal().toString().split(' ')[0] // Format date
      : 'N/A';
    final String diagnosis = record['diagnosis'] ?? 'N/A';
    final String prescription = record['prescription'] ?? 'N/A';
    final String tests = record['tests'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';

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
              // Option to add more actions like Edit/Delete here
            ],
          ),
          const Divider(height: 20, thickness: 1),
          _buildRecordDetailRow('Diagnosis:', diagnosis),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Prescription/Notes:', prescription),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Tests:', tests),
          const SizedBox(height: 8),
          _buildRecordDetailRow('Medications:', medications),
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

  Widget _buildLabAndRadiology() {
    // Implementation for Lab & Radiology tab
    return labReports.isEmpty && radiologyReports.isEmpty
        ? Center(
            child: Text('No lab or radiology reports found', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...labReports.map((report) => _buildReportCard('Lab Report', report)).toList(),
              ...radiologyReports.map((report) => _buildReportCard('Radiology Report', report)).toList(),
            ],
          );
  }

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
           if (report['desc']!.isNotEmpty) ...[
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

  void _showNewMedicalRecordDialog(BuildContext context) {
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
                        final String diagnoses = _conditionController.text.trim();
                        final String symptoms = _symptomsController.text.trim();
                        final String notes = _notesController.text.trim();
                        final String medications = _medicationsController.text.trim();
                        final String tests = _testsController.text.trim();

                        // Add the record to the database
                        await _addManualMedicalRecord(
                          diagnoses: '$diagnoses\nSymptoms: $symptoms', // Combine diagnosis and symptoms
                          prescription: notes, // Map notes to prescription
                          tests: tests,
                          medications: medications,
                        );

                        // Clear controllers and close dialog
                        // No need to dispose controllers here, they are disposed in the State's dispose method.
                        // conditionController.dispose();
                        // symptomsController.dispose();
                        // notesController.dispose();
                        // medicationsController.dispose();
                        // testsController.dispose();
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