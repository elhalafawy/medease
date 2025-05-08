import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/profile_picture.png'),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(Icons.star, color: Colors.orange, size: 16),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Dr. Ahmed is highly recommended for his compassionate approach and exceptional skill in cardiology.",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
} 