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
        'availability': 'Available Today',
        'nextSlot': '10:00 AM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF022E5B)),
          onPressed: onBack ?? () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Doctors',
          style: TextStyle(
            color: Color(0xFF022E5B),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
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
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailsScreen(
                doctor: doctor,
                onBack: () => Navigator.pop(context),
                onBookAppointment: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/appointment', arguments: doctor);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                image: DecorationImage(
                  image: AssetImage(doctor['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF022E5B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor['type'],
                                style: const TextStyle(
                                  color: Color(0xFFADADAD),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF022E5B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 14),
                              const SizedBox(width: 2),
                              Text(
                                doctor['rating'],
                                style: const TextStyle(
                                  color: Color(0xFF022E5B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF73D0ED)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor['hospital'],
                            style: const TextStyle(
                              color: Color(0xFF73D0ED),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 14, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                doctor['price'],
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF022E5B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Color(0xFF022E5B)),
                              const SizedBox(width: 2),
                              Text(
                                doctor['availability'],
                                style: const TextStyle(
                                  color: Color(0xFF022E5B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
