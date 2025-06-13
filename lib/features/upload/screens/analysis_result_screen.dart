import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../../home/screens/medication_reminder_screen.dart'; // Import the medication reminder screen
import '../../../core/supabase/medication_service.dart'; // Import the MedicationService
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
// You might need to import your medication reminder screen here
// import '../../medications/screens/add_medication_reminder_screen.dart'; 

class AnalysisResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisResultScreen({super.key, required this.result});

  Widget _buildSection(BuildContext context, String title, List<dynamic> items, IconData icon, {bool isMedications = false}) {
    // Create an instance of MedicationService to use in the callbacks
    final MedicationService _medicationService = MedicationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('No items found', style: TextStyle(color: Colors.grey))
        else if (isMedications)
          ...items.map((item) {
            final medication = item as Medication;
            return Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${medication.name}' + 
                      (medication.dosage.isNotEmpty ? ' (${medication.dosage})' : '') +
                      (medication.frequency.isNotEmpty ? ' - ${medication.frequency}' : ''),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_alarm, size: 20, color: Colors.blueAccent),
                    tooltip: 'Add Reminder',
                    onPressed: () async {
                      print('Attempting to navigate to Add Reminder for: ${medication.name}');
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicationReminderScreen(
                            initialName: medication.name,
                            initialDosage: medication.dosage,
                            initialFrequency: medication.frequency,
                            onConfirm: (name, dosage, startDate, endDate, frequency, reminderTimes, notes, _) async {
                              print('Attempting to save reminder for: $name');
                              
                              try {
                                final user = Supabase.instance.client.auth.currentUser;
                                if (user == null) {
                                  print('Error: User not authenticated.');
                                  if (context.mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('User not authenticated')),
                                     );
                                  }
                                  return;
                                }

                                final patient = await Supabase.instance.client
                                    .from('patients')
                                    .select('patient_id')
                                    .eq('user_id', user.id)
                                    .maybeSingle();

                                if (patient == null) {
                                   print('Error: Patient not found for user ${user.id}.');
                                   if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Patient profile not found')),
                                      );
                                   }
                                   return;
                                }
                                
                                final patientId = patient['patient_id'] as String;
                                print('Found patient ID: $patientId');

                                await _medicationService.addMedication(
                                  patientId: patientId,
                                  name: name,
                                  dosage: dosage,
                                  startDate: startDate,
                                  endDate: endDate,
                                  frequency: frequency,
                                  reminderTimes: reminderTimes,
                                  notes: notes,
                                );
                                print('Medication reminder saved successfully.');

                                if (context.mounted) {
                                   Navigator.pop(context);
                                   ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Reminder for $name saved!')),
                                   );
                                }

                              } catch (e, st) {
                                print('Error saving medication reminder: $e\n$st');
                                if (context.mounted) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Error saving reminder: ${e.toString()}')),
                                   );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList()
        else
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Text(item),
              )),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.patientName != null && result.patientName!.isNotEmpty)
              _buildSection(context, 'Patient Name', [result.patientName!], Icons.person),
            _buildSection(context, 'Diagnosis', result.diagnosis, Icons.medical_services),
            _buildSection(context, 'Symptoms', result.symptoms, Icons.sick),
            _buildSection(context, 'Medications', result.medications, Icons.medication, isMedications: true), // Mark as medications section
            _buildSection(context, 'Required Tests', result.labTests, Icons.science),
            _buildSection(context, 'Required Scans', result.radiologyScans, Icons.medical_information),
            const Divider(),
            const Text(
              'Raw Text:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(result.rawText),
          ],
        ),
      ),
    );
  }
} 