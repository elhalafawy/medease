import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PatientNotesScreen extends StatefulWidget {
  final String date;
  final String time;
  final String imageUrl;
  final VoidCallback onNoteAdded; // Updated: no longer passes count

  const PatientNotesScreen({
    super.key,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.onNoteAdded,
  });

  @override
  _PatientNotesScreenState createState() => _PatientNotesScreenState();
}

class _PatientNotesScreenState extends State<PatientNotesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Appointment Details',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(widget.imageUrl),
                    onBackgroundImageError: (_, __) => Icon(Icons.person, size: 30, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dr. Ahmed", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text("Neurologist | hospital", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                        const SizedBox(height: 4),
                        Text("Hourly Rate: 25.00 EGP", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text("4.8", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Schedule", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScheduleCard(title: widget.date, subtitle: "Date"),
                ScheduleCard(title: widget.time, subtitle: "Time"),
              ],
            ),
            const SizedBox(height: 24),
            Text("Message", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: "Write a message for the doctor",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: theme.colorScheme.surface,
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
                  widget.onNoteAdded();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text("Done", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
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
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }
}
