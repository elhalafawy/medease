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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(widget.doctor?['image'] ?? 'assets/images/doctor_photo.png'),
            ),
            const SizedBox(height:10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor?['name'] ?? "Dr. Ahmed",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.doctor?['type'] ?? "Senior Neurologist and Surgeon",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    widget.doctor?['hospital'] ?? "Mirpur Medical College and Hospital",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Appointment",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedDayIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedDayIndex = index);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF73D0ED) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dates[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Available Time",
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
                      color: isSelected ? const Color(0xFFEDAE73) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      times[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF9C9C9C),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isBooking ? null : _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF022E5B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: isBooking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Book Appointment',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Color(0xFF022E5B),
                      shape: CircleBorder(),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat, color: Colors.white),
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
                                  onNoteAdded: _incrementNoteCount, // ✅ call directly
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
