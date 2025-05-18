import 'package:flutter/material.dart';
import 'package:medease/features/appointment/doctor_Patient_Notes_Screen.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/utils/navigation_wrapper.dart';
import '../../../core/theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;

  const AppointmentScreen({
    super.key,
    this.doctor,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int selectedDayIndex = 2;
  int selectedTimeIndex = 0;
  bool isBooking = false;
  int notesCount = 0; // Track the number of notes added

  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  final List<String> dates = ['3', '4', '5', '6', '7'];
  final List<String> times = ['9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM'];

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Text(
            'Are you sure you want to book an appointment for ${days[selectedDayIndex]} at ${times[selectedTimeIndex]}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment() async {
    setState(() => isBooking = true);

    final newAppointment = {
      'doctorName': widget.doctor?['name'] ?? 'Dr. Ahmed',
      'specialty': widget.doctor?['type'] ?? 'Senior Neurologist and Surgeon',
      'hospital': widget.doctor?['hospital'] ?? 'Mirpur Medical College and Hospital',
      'date': '${days[selectedDayIndex]} ${dates[selectedDayIndex]}',
      'time': times[selectedTimeIndex],
      'status': 'Pending',
      'imageUrl': widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
    };

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isBooking = false);

    if (mounted) {
      CustomSnackBar.show(
        context: context,
        message: 'Appointment booked successfully for ${days[selectedDayIndex]} at ${times[selectedTimeIndex]}',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigation(
            goToAppointment: true,
            initialAppointments: [newAppointment],
          ),
        ),
      );
    }
  }

  void _incrementNoteCount() {
    setState(() {
      notesCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Book Appointment',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Doctor image at the top
          Container(
            width: double.infinity,
            height: 240,
            color: theme.scaffoldBackgroundColor,
            child: Image.asset(
              widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Floating DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.68,
            minChildSize: 0.68,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Doctor info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor?['name'] ?? "Dr. Ahmed",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.doctor?['type'] ?? "Senior Neurologist and Surgeon",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            widget.doctor?['hospital'] ?? "Mirpur Medical College and Hospital",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Appointment",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: List.generate(days.length, (index) {
                          final isSelected = index == selectedDayIndex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedDayIndex = index),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: index == 0 ? 8 : 0, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7DDCFF) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  children: [
                                    Text(
                                      days[index],
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dates[index],
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Available Times",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(times.length, (index) {
                        final isSelected = index == selectedTimeIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedTimeIndex = index);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.bookingTimeColor : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.shadowColor.withOpacity(0.18),
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              times[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isBooking ? null : _showConfirmationDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: isBooking
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Book Appointment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Ink(
                            decoration: const ShapeDecoration(
                              color: AppTheme.bookingDayColor,
                              shape: CircleBorder(),
                            ),
                            child: Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chat, color: AppTheme.primaryColor),
                                  onPressed: () {
                                    final selectedDate = '${dates[selectedDayIndex]} ${days[selectedDayIndex]}';
                                    final selectedTime = times[selectedTimeIndex];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PatientNotesScreen(
                                          date: selectedDate,
                                          time: selectedTime,
                                          imageUrl: widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
                                          onNoteAdded: _incrementNoteCount,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (notesCount > 0)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        '$notesCount',
                                        style: const TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
