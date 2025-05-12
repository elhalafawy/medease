import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gender_pie_chart.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/review_card.dart';
import 'doctor_reviews_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_notifications_screen.dart';
import 'doctor_profile_screen.dart';


class DoctorHomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const DoctorHomeScreen({super.key, this.onTabChange});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _showReviews = false;
  int newDoctorNotifCount = 3;
  List<Map<String, dynamic>> doctorAppointments = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            if (!_showReviews) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundImage: AssetImage('assets/images/doctor_photo.png'),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Welcome Dr.Ahmed, ",
                                          style: AppTheme.titleLarge.copyWith(
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const Text(
                                          "👋",
                                          style: AppTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const DoctorProfileScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.account_circle, size: 16, color: AppTheme.primaryColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Doctor Profile",
                                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                final displayAppointments = doctorAppointments.isEmpty
                                    ? [
                                        {
                                          'patient': 'Menna Ahmed',
                                          'date': '20.04.2023',
                                          'time': '16:30 - 18:30',
                                        },
                                        {
                                          'patient': 'Rana Mohamed',
                                          'date': '22.04.2023',
                                          'time': '11:00-16:00',
                                        },
                                      ]
                                    : doctorAppointments;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DoctorNotificationsScreen(
                                      appointmentsCount: displayAppointments.length,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.notifications_none, size: 32, color: AppTheme.primaryColor),
                                    if (newDoctorNotifCount > 0)
                                      Positioned(
                                        right: 2,
                                        top: 0,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            '$newDoctorNotifCount',
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Cards Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Gender Card
                              Container(
                                width: 108,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Gender",
                                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    const SizedBox(height: 65, width: 40, child: GenderPieChart()),
                                    const SizedBox(height: 2),
                                    const Column(
                                      children: [
                                        _GenderLegend(color: Color(0xFF3B82F6), label: 'Men'),
                                        SizedBox(height: 1),
                                        _GenderLegend(color: Color(0xFFEC4899), label: 'Women'),
                                        SizedBox(height: 1),
                                        _GenderLegend(color: Color(0xFF34D399), label: 'Children'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Messages Card
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const DoctorMessagesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 108,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Messages", style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13), textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Appointments Card
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          leading: IconButton(
                                            icon: const Icon(Icons.arrow_back),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                          title: const Text('Appointments'),
                                          backgroundColor: AppTheme.appBarBackgroundColor,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                        ),
                                        body: DoctorAppointmentsScreen(
                                          appointments: const [],
                                          onBack: () => Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 115,
                                  margin: const EdgeInsets.only(right: 0),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "0",
                                        style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Appointments", style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13), textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.star_border, color: AppTheme.primaryColor, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Analytics
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Analytics",
                              style: AppTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                Text(
                                  "This Week",
                                  style: AppTheme.bodyMedium,
                                ),
                                Icon(Icons.keyboard_arrow_down, size: 18, color: AppTheme.greyColor),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const AnalyticsChart(),
                        ),
                        const SizedBox(height: 24),
                        // Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Reviews",
                              style: AppTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showReviews = true;
                                });
                              },
                              child: Text(
                                "See All Reviews",
                                style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 4),
                            Text(
                              "4.8",
                              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Text("Total 0 Reviews", style: AppTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const ReviewCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textColor),
                            onPressed: () {
                              setState(() {
                                _showReviews = false;
                              });
                            },
                          ),
                          const Text(
                            'Reviews',
                            style: AppTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: DoctorReviewsScreen(showAppBar: false, showBottomBar: false),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenderLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _GenderLegend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.bodyMedium),
      ],
    );
  }
} 