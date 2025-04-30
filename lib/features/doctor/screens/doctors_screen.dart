import 'package:flutter/material.dart';
import 'doctor_details_screen.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/utils/navigation_wrapper.dart';

class DoctorsScreen extends StatelessWidget {
  final String category;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onDoctorTap;
  
  const DoctorsScreen({
    super.key,
    required this.category,
    this.onBack,
    this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'Dr. Ahmed',
        'type': 'Neurologist',
        'rating': '4.8',
        'patients': '116+',
        'experience': '3+ Years',
        'reviews': '90+',
        'image': 'assets/images/doctor_photo.png',
        'hospital': 'Al Shifa Hospital',
        'price': '300 EGP',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Doctors',
          style: TextStyle(color: Color(0xFF022E5B), fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: const Color(0xFFFDFDFD),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return _buildDoctorCard(context, doctor);
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return GestureDetector(
      onTap: () {
        if (onDoctorTap != null) {
          onDoctorTap!(doctor);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8F3F1)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(doctor['image']),
              radius: 35,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['type'],
                    style: const TextStyle(color: Color(0xFFADADAD), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['hospital'],
                    style: const TextStyle(color: Color(0xFF73D0ED), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(doctor['rating'], style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.attach_money, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(doctor['price'], style: const TextStyle(fontSize: 13, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}
