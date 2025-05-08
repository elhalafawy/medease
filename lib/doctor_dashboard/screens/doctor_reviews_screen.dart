import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text(
                'Reviews',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: displayReviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reviews from patients will appear here.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile_picture.png'),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['date'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                int.tryParse(review['rating'] ?? '0') ?? 0,
                                (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['message'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
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