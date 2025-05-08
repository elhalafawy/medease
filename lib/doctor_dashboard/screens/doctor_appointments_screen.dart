import 'package:flutter/material.dart';
import '../widgets/doctor_bottom_bar.dart';
import '../doctor_main_navigation.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final VoidCallback onBack;

  const DoctorAppointmentsScreen({
    super.key,
    required this.appointments,
    required this.onBack,
  });

  // الأيام المتاحة (true = متاح، false = غير متاح)
  final List<bool> availableDays = const [true, true, true, true, true, false, false];
  final List<String> daysShort = const ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'So'];

  static const List<Map<String, dynamic>> exampleAppointments = [
    {
      'patient': 'Menna Ahmed',
      'date': '20.04.2023',
      'time': '16:30 - 18:30',
    },
    {
      'patient': 'Rana Mohamed',
      'date': '22.04.2023',
      'time': '11:00-16:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayAppointments = appointments.isEmpty ? exampleAppointments : appointments;
    return SafeArea(
      child: Container(
        color: const Color(0xFFF9FAFB),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Your Appointment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF022E5B),
                  ),
                ),
                const SizedBox(height: 18),
                // Days bar with edit icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: availableDays[i] ? const Color(0xFF022E5B) : Colors.grey.shade300,
                    ),
                    onPressed: availableDays[i]
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Edit slots for ${daysShort[i]}')),
                            );
                          }
                        : null,
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: daysShort
                      .map((d) => Text(
                            d,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF022E5B),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                // Appointment cards
                ...displayAppointments.map((appt) => Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage('assets/images/profile_picture.png'),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appt['patient'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF022E5B),
                                      ),
                                    ),
                                    Material(
                                      color: const Color(0xFFF2F6FF),
                                      shape: const CircleBorder(),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF022E5B), size: 20),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Edit appointment for ${appt['patient']}')),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text('Date', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Text(
                                      appt['date'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 24),
                                    const Text('Time', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Text(
                                      appt['time'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 