import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart' as app_theme;
import '../widgets/doctor_bottom_bar.dart';

class DoctorReviewsScreen extends StatelessWidget {
  final bool showAppBar;
  final bool showBottomBar;

  const DoctorReviewsScreen({
    super.key,
    this.showAppBar = true,
    this.showBottomBar = true,
  });

  static const List<Map<String, String>> exampleReviews = [
    {
      'date': '2023-04-20',
      'title': 'Great Doctor',
      'rating': '5',
      'message': 'Very professional and caring. Highly recommended!'
    },
    {
      'date': '2023-04-18',
      'title': 'Excellent Service',
      'rating': '4',
      'message': 'The doctor was very attentive and helpful.'
    },
  ];

  final List<Map<String, String>> reviews = const [];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> displayReviews = reviews.isEmpty ? exampleReviews : reviews;
    return Scaffold(
      backgroundColor: app_theme.AppTheme.backgroundColor,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: app_theme.AppTheme.primaryColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                'Reviews',
                style: app_theme.AppTheme.titleLarge.copyWith(color: Colors.white),
              ),
              centerTitle: true,
            )
          : null,
      body: displayReviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mail_outline, size: 64, color: app_theme.AppTheme.greyColor),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: app_theme.AppTheme.titleLarge.copyWith(color: app_theme.AppTheme.greyColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reviews from patients will appear here.',
                    style: app_theme.AppTheme.bodyMedium.copyWith(color: app_theme.AppTheme.greyColor),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: displayReviews.length,
              itemBuilder: (context, index) {
                final review = displayReviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: app_theme.AppTheme.primaryColor.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile_picture.png'),
                        radius: 24,
                        backgroundColor: app_theme.AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['date'] ?? '',
                              style: app_theme.AppTheme.bodyMedium.copyWith(color: app_theme.AppTheme.greyColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review['title'] ?? '',
                              style: app_theme.AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: app_theme.AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                int.tryParse(review['rating'] ?? '0') ?? 0,
                                (i) => Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['message'] ?? '',
                              style: app_theme.AppTheme.bodyLarge.copyWith(color: app_theme.AppTheme.textColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: app_theme.AppTheme.greyColor),
                        onPressed: () {
                          // TODO: Show review options
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: showBottomBar ? const DoctorBottomBar(currentIndex: 0) : null,
    );
  }
} 