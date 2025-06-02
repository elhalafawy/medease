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

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('medical_records')
          .select('*, doctors!medical_records_doctor_id_fkey(name)')
          .order('created_at', ascending: false);

      setState(() {
        _records = List<Map<String, dynamic>>.from(response);
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
                  if (_records.isEmpty)
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
                    ..._records.map((record) => _buildRecordItem(
                      patientName: record['doctors']?['name'] ?? 'N/A',
                      diagnosis: record['medical_condition'] ?? 'N/A',
                      tests: record['tests'] ?? 'N/A',
                      medications: record['medications'] ?? 'N/A',
                      date: DateTime.parse(record['created_at']),
                      context: context,
                      theme: theme,
                    )),
                ],
              ),
            ),
    );
  }

  Widget _buildLabReportsButton(BuildContext context, ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LabReportsScreen()),
        );
      },
      icon: const Icon(Icons.science),
      label: const Text('View Lab Reports'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalRecordDetailsScreen(
                patientName: patientName,
                diagnosis: diagnosis,
                tests: tests,
                medications: medications,
                date: date,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    patientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Diagnosis: $diagnosis',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Tests: $tests',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Medications: $medications',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
