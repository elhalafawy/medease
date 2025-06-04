import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import 'patient_medical_record_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await _supabase
          .from('patients')
          .select(
              'patient_id, full_name, age, gender, contact_info, profile_image, date_of_birth, email')
          .order('full_name');

      setState(() {
        _patients = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_patients.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Patients',
            style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
          ),
        ),
        body: const Center(
          child: Text('No patients found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patients',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          final patientEmail = patient['email'] ?? 'N/A';
          final patientId = patient['patient_id'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                if (patientId != null && patientId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientMedicalRecordScreen(
                        patientName: patient['full_name'] ?? '',
                        patientAge: '${patient['age'] ?? 'N/A'} years',
                        patientId: patientId,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Patient record has no valid ID.')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: patient['profile_image'] != null
                              ? NetworkImage(patient['profile_image'])
                              : const AssetImage(
                                      'assets/images/profile_picture.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['full_name'] ?? 'N/A',
                                style: AppTheme.titleLarge.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Patient ID: ${patientId != null && patientId.isNotEmpty ? patientId.substring(0, 4) : 'N/A'}',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    _buildInfoRow('Age', '${patient['age'] ?? 'N/A'} years'),
                    const SizedBox(height: 15),
                    _buildInfoRow('Gender', patient['gender'] ?? 'N/A'),
                    const SizedBox(height: 15),
                    _buildInfoRow('Phone', patient['contact_info'] ?? 'N/A'),
                    const SizedBox(height: 15),
                    _buildInfoRow('Email', patientEmail),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                        'Date of Birth', patient['date_of_birth'] ?? 'N/A'),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Tap to view medical records',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.greyColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: label == 'Email' && value.contains('@')
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: value
                      .split('@')
                      .map((part) => Text(
                            part + (value.split('@').last != part ? '@' : ''),
                            textAlign: TextAlign.right,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ))
                      .toList(),
                )
              : Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
