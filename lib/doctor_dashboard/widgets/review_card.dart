import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final String? patientName;
  final double? rating;
  final String? reviewText;
  final String? reviewDate;

  const ReviewCard({
    super.key,
    this.patientName,
    this.rating,
    this.reviewText,
    this.reviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/profile_picture.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      patientName ?? 'Anonymous',
                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (reviewDate != null)
                      Text(
                        reviewDate!,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.greyColor),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) {
                      if (index < (rating ?? 0.0).floor()) {
                        return const Icon(Icons.star, color: Colors.amber, size: 18);
                      } else if (index < (rating ?? 0.0) && (rating ?? 0.0) % 1 != 0) {
                        return const Icon(Icons.star_half, color: Colors.amber, size: 18);
                      } else {
                        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reviewText ?? 'No review text available.',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 