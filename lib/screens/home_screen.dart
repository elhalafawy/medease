import 'package:flutter/material.dart';
import 'doctor_details_screen.dart';
import 'doctors_screen.dart';
import 'medication_screen.dart';
import 'medical_record_screen.dart'; // إضافة MedicalRecordScreen

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDoctorDetails = false;
  bool showMedication = false;
  bool showMedicalRecord = false; // تغيير هنا لإضافة السجل الطبي

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: showDoctorDetails
            ? DoctorDetailsScreen(
                onBack: () {
                  setState(() {
                    showDoctorDetails = false;
                  });
                },
                onBookAppointment: () {
                  widget.onTabChange?.call(2);
                },
              )
            : showMedication
                ? MedicationScreen(
                    onBack: () {
                      setState(() {
                        showMedication = false;
                      });
                    },
                  )
                : showMedicalRecord // عند الضغط على Medical Record نعرض الشاشة
                    ? const MedicalRecordScreen() // الصفحة المطلوبة
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/home_banner.png'),
                            const SizedBox(height: 20),
                            _buildSearchBar(),
                            const SizedBox(height: 24),
                            _buildQuickOptions(),
                            const SizedBox(height: 24),
                            _buildProtectionBanner(),
                            const SizedBox(height: 32),
                            const Text(
                              'New investigations',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3C4A59)),
                            ),
                            const SizedBox(height: 16),
                            _buildArticle(
                              title: 'What is the Replication Crisis?',
                              subtitle: 'This article will look at this subject, providing a brief overview.',
                              image: 'assets/images/article_1.png',
                            ),
                            _buildArticle(
                              title: 'Cardiology and pregnancy?',
                              subtitle: 'Although approximately 86% of practicing cardiologists surveyed...',
                              image: 'assets/images/article_2.png',
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategory('Doctors', Icons.person, const Color(0xFFFFE4E0), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorsScreen()),
          );
        }),
        _buildCategory('Medicine', Icons.medication_outlined, const Color(0xFFE7F0FF), () {
          setState(() {
            showMedication = true;
          });
        }),
        _buildCategory('Medical\nRecords', Icons.folder, const Color(0xFFFFF4DC), () {
          setState(() {
            showMedicalRecord = true; // هنا تم تفعيل عرض شاشة السجل الطبي
          });
        }),
      ],
    );
  }

  Widget _buildCategory(String label, IconData icon, Color color, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDBE3F7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Early protection for your health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00194A),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00194A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Learn more'),
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset('assets/images/doctor_male.png', height: 80),
        ],
      ),
    );
  }

  Widget _buildArticle({required String title, required String subtitle, required String image}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
