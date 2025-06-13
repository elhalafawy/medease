import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../doctor/screens/doctor_details_screen.dart';
import '../../doctor/screens/doctors_screen.dart';
import 'medication_screen.dart';
import 'medical_record_screen.dart';
import '../../appointment/screens/appointment_details_screen.dart';
import '../../appointment/screens/appointment_schedule_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/screens/notifications_screen.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'ocr_article_screen.dart';
import 'medical_record_article_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    int notificationCount = 3;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.nightBackground : AppTheme.backgroundColor,
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
                            category: 'All',
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.kPaddingXLarge,
                                      vertical: AppTheme.kPaddingLarge,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/home_banner.png'),
                                        const SizedBox(height: AppTheme.kPaddingXLarge),
                                        _buildUserWelcome(authProvider, isDarkMode),
                                        const SizedBox(height: AppTheme.kPaddingXLarge),
                                        _buildQuickOptions(isDarkMode),
                                        const SizedBox(height: AppTheme.kPaddingXLarge),
                                        _buildProtectionBanner(isDarkMode),
                                        const SizedBox(height: AppTheme.kPaddingXLarge),
                                        Text(
                                          'New investigations',
                                          style: isDarkMode ? AppTheme.nightTitleLarge : AppTheme.titleLarge,
                                        ),
                                        const SizedBox(height: AppTheme.kPaddingLarge),
                                        _buildArticle(
                                          title: 'Unlocking Health Data: The Power of OCR in MedEase',
                                          subtitle: 'This article explores how OCR technology is used in the MedEase application to digitize medical records and its benefits.',
                                          image: 'assets/images/ocr_illustration.png',
                                          isDarkMode: isDarkMode,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const OcrArticleScreen()),
                                            );
                                          },
                                        ),
                                        _buildArticle(
                                          title: 'Unlock Better Health with Digital Records',
                                          subtitle: 'Explore how MedEase helps you manage and access your medical records efficiently, ensuring better health outcomes.',
                                          image: 'assets/images/Medical_record.jpg',
                                          isDarkMode: isDarkMode,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const MedicalRecordArticleScreen()),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
            Positioned(
              top: AppTheme.kPaddingMedium,
              right: AppTheme.kPaddingMedium,
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
                      padding: const EdgeInsets.all(AppTheme.kPaddingSmall),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.nightCard : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: AppTheme.kElevationMedium,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        color: isDarkMode ? AppTheme.nightPrimary : AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: AppTheme.errorColor,
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppTheme.kFontSizeXS,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildUserWelcome(AuthProvider authProvider, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, ${authProvider.userName ?? "Guest"} 👋',
          style: isDarkMode ? AppTheme.nightHeadlineMedium : AppTheme.headlineMedium,
        ),
        const SizedBox(height: AppTheme.kPaddingSmall),
        Text(
          'Hope you are doing well today!',
          style: isDarkMode ? AppTheme.nightBodyMedium : AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPaddingLarge),
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.nightInput : Colors.white,
        border: Border.all(color: isDarkMode ? AppTheme.nightBorder : AppTheme.borderColor),
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusLarge),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: isDarkMode ? AppTheme.nightGrey : AppTheme.greyColor,
          ),
          const SizedBox(width: AppTheme.kPaddingMedium),
          Expanded(
            child: TextField(
              style: isDarkMode ? AppTheme.nightBodyLarge : AppTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: isDarkMode ? AppTheme.nightBodyMedium : AppTheme.bodyMedium,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOptions(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategory(
          'Doctors',
          Icons.person,
          const Color(0xFFFFE4E0),
          () {
            setState(() {
              showDoctors = true;
            });
          },
          isDarkMode,
        ),
        _buildCategory(
          'Medicine',
          Icons.medication_outlined,
          const Color(0xFFE7F0FF),
          () {
            setState(() {
              showMedication = true;
            });
          },
          isDarkMode,
        ),
        _buildCategory(
          'Medical\nRecords',
          Icons.folder,
          const Color(0xFFFFF4DC),
          () {
            setState(() {
              showMedicalRecord = true;
            });
          },
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildCategory(String label, IconData icon, Color color, [VoidCallback? onTap, bool isDarkMode = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        height: 90,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.nightCard : color,
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusLarge),
          border: Border.all(color: isDarkMode ? AppTheme.nightBorder : AppTheme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: isDarkMode ? AppTheme.nightText : AppTheme.textColor,
            ),
            const SizedBox(height: AppTheme.kPaddingSmall),
            Text(
              label,
              style: isDarkMode ? AppTheme.nightBodyLarge : AppTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionBanner(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.nightCard : const Color(0xFFDBE3F7),
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusXLarge),
      ),
      padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Early protection for your health',
                  style: TextStyle(
                    fontSize: AppTheme.kFontSizeMD,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppTheme.nightText : AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.kPaddingMedium),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppTheme.nightPrimary : AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Learn more',
                    style: (isDarkMode ? AppTheme.nightLabelLarge : AppTheme.labelLarge).copyWith(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: AppTheme.kPaddingMedium),
          Image.asset('assets/images/doctor_male.png', height: 80),
        ],
      ),
    );
  }

  Widget _buildArticle({
    required String title,
    required String subtitle,
    required String image,
    bool isDarkMode = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppTheme.kPaddingSmall),
        padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.nightCard : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: AppTheme.kElevationMedium,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
              child: Image.asset(image, width: 70, height: 70, fit: BoxFit.cover),
            ),
            const SizedBox(width: AppTheme.kPaddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: isDarkMode ? AppTheme.nightTitleMedium : AppTheme.titleMedium,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: AppTheme.kPaddingSmall),
                  Text(
                    subtitle,
                    style: isDarkMode ? AppTheme.nightBodyMedium : AppTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
