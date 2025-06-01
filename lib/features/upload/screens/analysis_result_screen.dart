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

  Widget _buildSection(BuildContext context, String title, List<String> items, IconData icon, {bool isMedications = false}) {
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
        else
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 32, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item)),
                    if (isMedications) // Add button only for medications
                      IconButton(
                        icon: const Icon(Icons.add_alarm, size: 20, color: Colors.blueAccent), // Reminder icon
                        tooltip: 'Add Reminder',
                        onPressed: () async { // Made onPressed async
                          print('Attempting to navigate to Add Reminder for: $item'); // Debug print
                          
                          // Navigate to the add reminder screen and pass the medication name
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicationReminderScreen(
                                initialName: item, // Pass the medication name
                                onConfirm: (name, dosage, startDate, endDate, frequency, reminderTimes, notes, _) async { // Updated onConfirm signature
                                  print('Attempting to save reminder for: $name'); // Debug print
                                  
                                  try {
                                    // Get current user and patient ID
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
                                    
                                    final patientId = patient['patient_id'] as String; // Assuming patient_id is String
                                    print('Found patient ID: $patientId'); // Debug print

                                    // Save the medication reminder to Supabase
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
                                    print('Medication reminder saved successfully.'); // Debug print

                                    // Optionally, navigate back after saving
                                    if (context.mounted) {
                                       Navigator.pop(context);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Reminder for $name saved!')),
                                       );
                                    }

                                  } catch (e, st) {
                                    print('Error saving medication reminder: $e\n$st'); // Debug print
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
            _buildSection(context, 'Diagnosis', [result.diagnosis], Icons.medical_services),
            _buildSection(context, 'Symptoms', result.symptoms, Icons.sick),
            _buildSection(context, 'Medications', result.medications, Icons.medication, isMedications: true), // Mark as medications section
            _buildSection(context, 'Required Tests', result.requiredTests, Icons.science),
            _buildSection(context, 'Required Scans', result.requiredScans, Icons.medical_information),
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