import 'package:flutter/material.dart';
import '../../core/widgets/custom_bottom_bar.dart';

class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({super.key});

  // قائمة الريفيوهات (تبدأ فاضية)
  final List<Map<String, String>> reviews = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Reviews', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: reviews.isEmpty
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
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/patient.png'),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review['date'] ?? '', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              review['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                int.tryParse(review['rating'] ?? '0') ?? 0,
                                (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(review['message'] ?? '', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert, color: Colors.grey),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 0),
    );
  }
} 