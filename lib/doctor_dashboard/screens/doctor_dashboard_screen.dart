import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart' as app_theme;
import '../../core/widgets/custom_bottom_bar.dart';
import '../widgets/gender_pie_chart.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/review_card.dart';
import 'doctor_reviews_screen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: app_theme.AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  "👋",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 32, color: app_theme.AppTheme.primaryColor),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Cards Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gender Card
                    Expanded(
                      flex: 2,
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Gender",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(height: 70, child: GenderPieChart()),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                _GenderLegend(color: Color(0xFF3B82F6), label: 'Men'),
                                _GenderLegend(color: Color(0xFF60A5FA), label: 'Women'),
                                _GenderLegend(color: Color(0xFF34D399), label: 'Children'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Messages Card
                    Expanded(
                      flex: 1,
                      child: Container(
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
                        child: Column(
                          children: [
                            Text(
                              "0",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: app_theme.AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Messages", style: TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            Icon(Icons.chat_bubble_outline, color: Color(0xFF3B82F6), size: 28),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Appointments Card
                    Expanded(
                      flex: 1,
                      child: Container(
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
                        child: Column(
                          children: [
                            Text(
                              "0",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: app_theme.AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Appointments", style: TextStyle(fontSize: 13)),
                            const SizedBox(height: 8),
                            Icon(Icons.star_border, color: Color(0xFF6366F1), size: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DoctorReviewsScreen()),
                        );
                      },
                      child: const Text(
                        "See All Reviews",
                        style: TextStyle(color: app_theme.AppTheme.primaryColor),
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
      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
}

class _GenderLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _GenderLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
} 