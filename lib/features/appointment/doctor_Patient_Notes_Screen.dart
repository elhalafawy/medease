import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PatientNotesScreen extends StatefulWidget {
  final String date;
  final String time;
  final String imageUrl;
  final void Function(String) onNoteAdded;

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
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitNote() async {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('notes').insert({
        'note': noteText,
        'date': widget.date,
        'time': widget.time,
        'doctor_name': 'Dr. Ahmed',
        'created_at': DateTime.now().toIso8601String(),
      });

      widget.onNoteAdded(noteText);
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Appointment Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
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
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    backgroundImage: AssetImage(widget.imageUrl),
                    onBackgroundImageError: (_, __) => Icon(Icons.person, size: 30, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dr. Ahmed", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text("Neurologist | hospital", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text("Hourly Rate: 25.00 EGP", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text("4.8", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Schedule", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ScheduleCard(
                  title: DateFormat('EEE, MMM dd, yyyy').format(
                    DateTime.parse(widget.date.split(' ')[0]),
                  ),
                  subtitle: "Date",
                ),
                ScheduleCard(
                  title: formatTimeTo12Hour(widget.time),
                  subtitle: "Time",
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Message", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: "Write a message for the doctor",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNoteAdded(_noteController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(
                        "Done",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

String formatTimeTo12Hour(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  final period = hour < 12 ? 'AM' : 'PM';
  final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
  return '${formattedHour}:${minute.toString().padLeft(2, '0')} $period';
}
