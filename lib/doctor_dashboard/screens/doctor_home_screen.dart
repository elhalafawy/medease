import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gender_pie_chart.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/review_card.dart';
import 'doctor_reviews_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_notifications_screen.dart';


class DoctorHomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const DoctorHomeScreen({super.key, this.onTabChange});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _showReviews = false;


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
                                CircleAvatar(
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
                                        Text(
                                          "👋",
                                          style: AppTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.edit, size: 16, color: AppTheme.greyColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Edit Profile",
                                          style: AppTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const DoctorNotificationsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.notifications_none, size: 32, color: AppTheme.primaryColor),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorColor,
                                          shape: BoxShape.circle,
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
                                  color: Color(0xFFF7FAFC),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Color(0xFFB6D0F7), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha((0.08 * 255).toInt()),
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
                                    SizedBox(height: 65, width: 40, child: GenderPieChart()),
                                    const SizedBox(height: 2),
                                    Column(
                                      children: const [
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
                                    color: Color(0xFFF7FAFC),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Color(0xFFB6D0F7), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withAlpha((0.08 * 255).toInt()),
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
                                          color: const Color(0xFFECF7F6),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF3B82F6), size: 18),
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
                                          backgroundColor: Colors.white,
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
                                  width: 108,
                                  margin: const EdgeInsets.only(right: 0),
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF7FAFC),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Color(0xFFB6D0F7), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withAlpha((0.08 * 255).toInt()),
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
                                        style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF6366F1), fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text("Appointments", style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF6366F1), fontSize: 13), textAlign: TextAlign.center),
                                      const SizedBox(height: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF1FB),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(Icons.star_border, color: Color(0xFF6366F1), size: 18),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Analytics",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  "This Week",
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
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
                          child: AnalyticsChart(),
                        ),
                        const SizedBox(height: 24),
                        // Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Reviews",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showReviews = true;
                                });
                              },
                              child: const Text(
                                "See All Reviews",
                                style: TextStyle(color: AppTheme.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 24),
                            SizedBox(width: 4),
                            Text(
                              "0.0",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(width: 8),
                            Text("Total 0 Reviews", style: TextStyle(fontSize: 14)),
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
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _showReviews = false;
                              });
                            },
                          ),
                          const Text(
                            'Reviews',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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