import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> medicalRecords = [
    // {
    //   'date': '15 Mar, 2024',
    //   'condition': 'Upper Respiratory Infection',
    //   'symptoms': 'Fever, Cough, Sore Throat',
    //   'notes': 'Patient presented with symptoms of common cold. Prescribed antibiotics and rest.',
    //   'doctor': 'Dr. Ahmed',
    // },
  ];

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Medical Records', style: AppTheme.titleLarge),
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
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: AppTheme.bodyLarge,
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
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyLarge.copyWith(
              color: selected ? Colors.white : AppTheme.primaryColor,
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
    return medicalRecords.isEmpty
        ? _buildEmptyMedicalRecord()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicalRecords.length,
            itemBuilder: (context, index) => _buildMedicalRecordCard(medicalRecords[index], index),
          );
  }

  Widget _buildEmptyMedicalRecord() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.medical_services_outlined, size: 60, color: AppTheme.greyColor),
          const SizedBox(height: 18),
          Text('No medical records found', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text(
            'Create a new medical record for ${widget.patientName}',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
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
                  record['date'],
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record['doctor'],
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Condition: ${record['condition']}',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Symptoms: ${record['symptoms']}',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Notes: ${record['notes']}',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditMedicalRecordDialog(context, record, index);
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
                  onPressed: () {},
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

  void _showEditMedicalRecordDialog(BuildContext context, Map<String, dynamic> record, int index) {
    final TextEditingController conditionController = TextEditingController(text: record['condition'] ?? '');
    final TextEditingController symptomsController = TextEditingController(text: record['symptoms'] ?? '');
    final TextEditingController notesController = TextEditingController(text: record['notes'] ?? '');
    final TextEditingController medicationsController = TextEditingController(text: record['medications'] ?? '');
    final TextEditingController testsController = TextEditingController(text: record['tests'] ?? '');
    InputDecoration themedInputDecoration({required String label, IconData? icon}) {
      return InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      );
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
                controller: conditionController,
                decoration: themedInputDecoration(label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: symptomsController,
                decoration: themedInputDecoration(label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationsController,
                decoration: themedInputDecoration(label: 'Required Medications', icon: Icons.medication),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: testsController,
                decoration: themedInputDecoration(label: 'Required Tests', icon: Icons.science),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          medicalRecords[index] = {
                            'date': record['date'],
                            'condition': conditionController.text,
                            'symptoms': symptomsController.text,
                            'notes': notesController.text,
                            'doctor': record['doctor'],
                            'medications': medicationsController.text,
                            'tests': testsController.text,
                          };
                        });
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
                      child: const Text('Update'),
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
    final TextEditingController conditionController = TextEditingController();
    final TextEditingController symptomsController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    final TextEditingController medicationsController = TextEditingController();
    final TextEditingController testsController = TextEditingController();

    InputDecoration themedInputDecoration({required String label, IconData? icon}) {
      return InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryColor) : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      );
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
                controller: conditionController,
                decoration: themedInputDecoration(label: 'Medical Condition', icon: Icons.sick),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: symptomsController,
                decoration: themedInputDecoration(label: 'Symptoms', icon: Icons.healing),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: themedInputDecoration(label: 'Notes', icon: Icons.note_alt),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medicationsController,
                decoration: themedInputDecoration(label: 'Required Medications', icon: Icons.medication),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: testsController,
                decoration: themedInputDecoration(label: 'Required Tests', icon: Icons.science),
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          medicalRecords.add({
                            'date': DateTime.now().toString().substring(0, 10),
                            'condition': conditionController.text,
                            'symptoms': symptomsController.text,
                            'notes': notesController.text,
                            'doctor': 'Dr. Ahmed',
                            'medications': medicationsController.text,
                            'tests': testsController.text,
                          });
                        });
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

  Widget _buildLabAndRadiology() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.greyColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'Lab Tests'),
                Tab(text: 'Radiology'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReportsList(labReports),
                _buildReportsList(radiologyReports),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(List<Map<String, dynamic>> reports) {
    return reports.isEmpty
        ? _buildEmptyState('No reports found')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) => _buildReportCard(reports[index]),
          );
  }

  Widget _buildMedications() {
    return medications.isEmpty
        ? _buildEmptyState('No medications found')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) => _buildMedicationCard(medications[index]),
          );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
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
                child: Text(report['title'], style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.more_vert, color: AppTheme.greyColor),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(report['date'], style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              if (report['result'] != null && report['result'].toString().isNotEmpty) ...[
                const Text(' . '),
                Text(
                  report['result'],
                  style: AppTheme.bodyMedium.copyWith(color: report['statusColor'], fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          if (report['desc'] != null && report['desc'].toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(report['desc'], style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, color: AppTheme.primaryColor),
                  label: Text('View Report', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
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
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: AppTheme.primaryColor),
                  label: Text('Download', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryColor),
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
                child: Text(medication['name'], style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: medication['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  medication['status'],
                  style: AppTheme.bodyMedium.copyWith(
                    color: medication['statusColor'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMedicationInfo('Dosage', medication['dosage']),
          _buildMedicationInfo('Frequency', medication['frequency']),
          _buildMedicationInfo('Duration', medication['duration']),
        ],
      ),
    );
  }

  Widget _buildMedicationInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedTab == 0 ? Icons.science : selectedTab == 1 ? Icons.science : Icons.medication,
            size: 60,
            color: AppTheme.greyColor,
          ),
          const SizedBox(height: 18),
          Text(message, style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text(
            'No records available at the moment.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 