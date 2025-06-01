import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'patient_medical_record_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      // Not logged in
      return;
    }

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      userData = response;
    });
  }

  String calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return '$age years';
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final fullName = userData!['full_name'] ?? 'Unknown';
    final email = userData!['email'] ?? 'Unknown';
    final phone = userData!['phone'] ?? 'Unknown';
    final gender = userData!['gender'] ?? 'N/A';
    final bloodType = userData!['blood_type'] ?? 'N/A';
    final birthDateStr = userData!['birth_date'] ?? '2000-01-01';
    final DateTime birthDate = DateTime.tryParse(birthDateStr) ?? DateTime(2000);
    final String age = calculateAge(birthDate);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Patient Profile',
          style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientMedicalRecordScreen(
                      patientName: fullName,
                      patientAge: age,
                      patientId: userData!['id'],
                    ),
                  ),
                );
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
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/images/profile_picture.png'),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: AppTheme.titleLarge.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Patient ID: ${userData!['id']}',
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
                    _buildInfoRow('Age', age),
                    const SizedBox(height: 15),
                    _buildInfoRow('Gender', gender),
                    const SizedBox(height: 15),
                    _buildInfoRow('Blood Type', bloodType),
                    const SizedBox(height: 15),
                    _buildInfoRow('Phone', phone),
                    const SizedBox(height: 15),
                    _buildInfoRow('Email', email),
                    const SizedBox(height: 15),
                    _buildInfoRow('Date of Birth', birthDateStr),
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
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
    );
  }
}