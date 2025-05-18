import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../doctor/screens/doctor_details_screen.dart';
import '../../doctor/screens/doctors_screen.dart';
import 'medication_screen.dart';
import 'medical_record_screen.dart';
import '../../appointment/screens/appointment_details_screen.dart';
import '../../appointment/screens/appointment_schedule_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDoctors = false;
  bool showDoctorDetails = false;
  bool showAppointmentDetails = false;
  bool showMedication = false;
  bool showMedicalRecord = false;
  bool showAppointmentSchedule = false;
  Map<String, dynamic>? selectedDoctor;
  Map<String, dynamic>? selectedAppointment;
  List<Map<String, dynamic>> appointments = [
    {
      'doctorName': 'Dr. Ahmed',
      'specialty': 'Neurologist',
      'hospital': 'Al Shifa Hospital',
      'date': '6 Jun, Sun',
      'time': '10:30am - 11:30pm',
      'status': 'Pending',
      'rating': 4.8,
      'price': '300 EGP',
      'message': 'Please be on time.',
      'imageUrl': 'assets/images/doctor_photo.png',
    },
  ];
  User? user;
  String category = 'All';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int notificationCount = 3; // يمكنك ربطها بالعدادات الحقيقية لاحقًا
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            showAppointmentDetails && selectedAppointment != null
                ? AppointmentDetailsScreen(
                    appointment: selectedAppointment!,
                    onBack: () {
                      setState(() {
                        selectedAppointment = null;
                      });
                    },
                  )
                : showAppointmentSchedule
                    ? AppointmentScheduleScreen(
                        appointments: appointments,
                        onBack: () {
                          setState(() {
                            showAppointmentSchedule = false;
                          });
                        },
                        onSelectAppointment: (appointment) {
                          setState(() {
                            selectedAppointment = appointment;
                            showAppointmentDetails = true;
                            showAppointmentSchedule = false;
                          });
                        },
                      )
                : showDoctorDetails && selectedDoctor != null
                    ? DoctorDetailsScreen(
                        doctor: selectedDoctor!,
                        onBack: () {
                          setState(() {
                            showDoctorDetails = false;
                          });
                        },
                      )
                    : showDoctors
                        ? DoctorsScreen(
                            category: category,
                            onBack: () {
                              setState(() {
                                showDoctors = false;
                              });
                            },
                            onDoctorTap: (doctor) {
                              setState(() {
                                selectedDoctor = doctor;
                                showDoctorDetails = true;
                                showDoctors = false;
                              });
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
                            : showMedicalRecord
                                ? MedicalRecordScreen(onBack: () {
                                    if (widget.onTabChange != null) {
                                      widget.onTabChange!(0);
                                    }
                                    setState(() {
                                      showMedicalRecord = false;
                                    });
                                  })
                                : SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/home_banner.png'),
                                        const SizedBox(height: 20),
                                        _buildUserWelcome(),
                                        const SizedBox(height: 20),
                                        _buildSearchBar(),
                                        const SizedBox(height: 24),
                                        _buildQuickOptions(),
                                        const SizedBox(height: 24),
                                        _buildProtectionBanner(),
                                        const SizedBox(height: 32),
                                        const Text(
                                          'New investigations',
                                          style: AppTheme.titleLarge,
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
            // Notification icon (always visible at top right)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_none, color: AppTheme.primaryColor, size: 28),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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

  Widget _buildUserWelcome() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${user?.displayName?? "Guest"} 👋', 
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hope you are doing well today!',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: AppTheme.greyColor),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategory('Doctors', Icons.person, const Color(0xFFFFE4E0), () {
          setState(() {
            showDoctors = true;
          });
        }),
        _buildCategory('Medicine', Icons.medication_outlined, const Color(0xFFE7F0FF), () {
          setState(() {
            showMedication = true;
          });
        }),
        _buildCategory('Medical\nRecords', Icons.folder, const Color(0xFFFFF4DC), () {
          setState(() {
            showMedicalRecord = true;
          });
        }),
      ],
    );
  }

  Widget _buildCategory(String label, IconData icon, Color color, [VoidCallback? onTap]) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: AppTheme.textColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionBanner() {
    final theme = Theme.of(context);
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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

