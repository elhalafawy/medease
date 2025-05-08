import 'package:flutter/material.dart';
import '../../doctor/screens/doctor_details_screen.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/utils/navigation_wrapper.dart';
import 'appointment_schedule_screen.dart';

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
                backgroundColor: const Color(0xFF022E5B),
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
    
    // Create new appointment data
    final newAppointment = {
      'doctorName': widget.doctor?['name'] ?? 'Dr. Ahmed',
      'specialty': widget.doctor?['type'] ?? 'Senior Neurologist and Surgeon',
      'hospital': widget.doctor?['hospital'] ?? 'Mirpur Medical College and Hospital',
      'date': '${days[selectedDayIndex]} ${dates[selectedDayIndex]}',
      'time': times[selectedTimeIndex],
      'status': 'Pending',
      'imageUrl': widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
    };
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => isBooking = false);
    
    if (mounted) {
      CustomSnackBar.show(
        context: context,
        message: 'Appointment booked successfully for ${days[selectedDayIndex]} at ${times[selectedTimeIndex]}',
      );
      
      // Navigate to the main navigation with appointments tab selected and pass the new appointment
      if (mounted) {
        // First pop the current screen
        Navigator.pop(context);
        
        // Then navigate to the main navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                goToAppointment: true,
                initialAppointments: [newAppointment],
              ),
            ),
          );
        });
      }
    }
  }

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
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF022E5B),
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
              child: SizedBox(
                width: double.infinity,
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
