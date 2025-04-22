import 'package:flutter/material.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String hospital;
  final String imageUrl;
  final double rating;
  final String price;
  final String date;
  final String time;
  final String? message;

  const AppointmentDetailsScreen({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.date,
    required this.time,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.favorite_border, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('$specialty | $hospital', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Hourly Rate: $price', style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Date', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Time', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text('Message', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
              ),
              width: double.infinity,
              child: Text(
                message?.isNotEmpty == true ? message! : 'No message provided',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF022E5B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
