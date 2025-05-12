import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PatientNotesScreen extends StatefulWidget {
  final String date;
  final String time;
  final String imageUrl;
  final VoidCallback onNoteAdded; // Updated: no longer passes count

  const PatientNotesScreen({
    Key? key,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.onNoteAdded,
  }) : super(key: key);

  @override
  _PatientNotesScreenState createState() => _PatientNotesScreenState();
}

class _PatientNotesScreenState extends State<PatientNotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        title: const Text(
          'Appointment Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Doctor Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(widget.imageUrl),
                    onBackgroundImageError: (_, __) =>
                        const Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Dr. Ahmed",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Neurologist | hospital",
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text("Hourly Rate: 25.00 EGP",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Text("4.8"),
                      Icon(Icons.star, color: Colors.amber),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Schedule Info
            const Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScheduleCard(title: widget.date, subtitle: "Date"),
                ScheduleCard(title: widget.time, subtitle: "Time"),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Write a message for the doctor",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNoteAdded(); // Notify parent
                  Navigator.pop(context); // Close screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1C5B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScheduleCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
