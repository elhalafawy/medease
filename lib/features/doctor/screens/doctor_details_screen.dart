import 'package:flutter/material.dart';
import '../../appointment/screens/appointment_screen.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/utils/navigation_wrapper.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onBack;
  final VoidCallback? onBookAppointment;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    this.onBack,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Doctor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(doctor['image']),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF022E5B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(doctor['type'], style: const TextStyle(color: Colors.white70)),
                  const Text("Mirpur Medical College and Hospital", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Appointment", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DoctorStat(icon: Icons.person, value: doctor['patients'], label: 'Patients'),
                _DoctorStat(icon: Icons.verified_user, value: doctor['experience'], label: 'Years'),
                _DoctorStat(icon: Icons.star_border, value: doctor['rating'], label: 'Rating'),
                _DoctorStat(icon: Icons.chat, value: doctor['reviews'], label: 'Reviews'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppointmentScreen()),
              );
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF022E5B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DoctorStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF022E5B), size: 30),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
