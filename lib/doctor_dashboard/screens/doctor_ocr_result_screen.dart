import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/upload/models/analysis_result.dart';
import 'patient_medical_record_screen.dart';

class DoctorOcrResultScreen extends StatelessWidget {
  final AnalysisResult analysis;
  final String patientId;
  final String patientName;
  final String patientDOB;

  const DoctorOcrResultScreen({
    super.key,
    required this.analysis,
    required this.patientId,
    required this.patientName,
    required this.patientDOB,
  });

  Future<void> _saveToMedicalRecord(BuildContext context) async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content:
            const Text('Do you want to save the data to the medical record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      try {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
          return;
        }
        final doctorResponse = await Supabase.instance.client
            .from('doctors')
            .select('doctor_id')
            .eq('user_id', currentUser.id)
            .maybeSingle();
        if (doctorResponse == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doctor profile not found')),
          );
          return;
        }
        final doctorId = doctorResponse['doctor_id'];
        await Supabase.instance.client.from('medical_records').insert({
          'patient_id': patientId,
          'doctor_id': doctorId,
          'medical_condition': analysis.diagnosis,
          'symptoms': analysis.symptoms.join(', '),
          'notes': analysis.rawText,
          'tests': analysis.requiredTests.join(', '),
          'medications': analysis.medications.join(', '),
          'created_at': DateTime.now().toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record saved successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientMedicalRecordScreen(
              patientName: patientName,
              patientAge: patientDOB,
              patientId: patientId,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medical record: $e')),
        );
      }
    }
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        if (items.isEmpty)
          const Text('No data', style: TextStyle(color: Colors.grey)),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(e),
            )),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnosis:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(analysis.diagnosis.isNotEmpty
                  ? analysis.diagnosis
                  : 'No diagnosis'),
              const SizedBox(height: 12),
              _buildSection('Symptoms', analysis.symptoms),
              _buildSection('Medications', analysis.medications),
              _buildSection('Required Tests', analysis.requiredTests),
              _buildSection('Required Scans', analysis.requiredScans),
              const Divider(),
              const Text('Raw Text:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(analysis.rawText),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveToMedicalRecord(context),
                  child: const Text('Save to Medical Record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
