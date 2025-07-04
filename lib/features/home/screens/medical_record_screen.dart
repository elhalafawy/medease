import 'package:flutter/material.dart';
import 'medical_record_details_screen.dart';
import 'lab_reports_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MedicalRecordScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const MedicalRecordScreen({super.key, this.onBack});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  int? _selectedMonth;
  List<int> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() => _isLoading = true);

      // Get the current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in.')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Get the patient_id for the current user
      final patientResponse = await _supabase
          .from('patients')
          .select('patient_id')
          .eq('user_id', user.id)
          .single();

      final patientId = patientResponse['patient_id'];

      // Fetch medical records for this patient
      final response = await _supabase
          .from('medical_records')
          .select('*, doctors!medical_records_doctor_id_fkey(name), lab_reports(report_id, Title, created_at, status), Radiology(Radiology_id, Title, created_at, status)')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      setState(() {
        _records = List<Map<String, dynamic>>.from(response);
        _availableMonths = _records
            .map((r) => DateTime.parse(r['created_at']).month)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Descending order
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading medical records: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var filteredRecords = _selectedMonth == null
      ? _records
      : _records.where((r) => DateTime.parse(r['created_at']).month == _selectedMonth).toList();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabReportsButton(context, theme),
                  const SizedBox(height: 16),
                  _buildMonthFilter(theme),
                  const SizedBox(height: 16),
                  if (filteredRecords.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(height: 18),
                          Text('No medical records found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                        ],
                      ),
                    )
                  else
                    ...filteredRecords.map((record) => _buildRecordItem(
                      record: record,
                      context: context,
                      theme: theme,
                    )),
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
        icon: const Icon(Icons.science),
        label: const Text('View Lab Reports & Radiology'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int monthNumber) {
    final List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[monthNumber - 1];
  }

  Widget _buildMonthFilter(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text('All'),
            selected: _selectedMonth == null,
            onSelected: (_) => setState(() => _selectedMonth = null),
          ),
          ..._availableMonths.map((month) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(_getMonthName(month)),
              selected: _selectedMonth == month,
              onSelected: (_) => setState(() => _selectedMonth = month),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecordItem({
    required Map<String, dynamic> record,
    required BuildContext context,
    required ThemeData theme,
  }) {
    final String doctorName = record['doctors']?['name'] ?? 'N/A';
    final String diagnosis = record['medical_condition'] ?? 'N/A';
    final String medications = record['medications'] ?? 'N/A';
    final String symptoms = record['symptoms'] ?? 'N/A';
    final String notes = record['notes'] ?? 'N/A';
    final DateTime date = DateTime.parse(record['created_at']);

    final List<Map<String, dynamic>> labReports = (record['lab_reports'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final List<Map<String, dynamic>> radiologyReports = (record['Radiology'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalRecordDetailsScreen(
              patientName: doctorName,
              symptoms: symptoms,
              labReports: labReports,
              radiologyReports: radiologyReports,
              medications: medications,
              notes: notes,
              date: date,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
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
                    'Doctor: $doctorName',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Diagnosis: $diagnosis',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  if (labReports.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Lab Tests:',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: labReports.map((report) => Text(
                        report['Title'] ?? 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      )).toList(),
                    ),
                  ],
                  if (radiologyReports.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Radiology Tests:',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: radiologyReports.map((report) => Text(
                        report['Title'] ?? 'N/A',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                      )).toList(),
                    ),
                  ],
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
