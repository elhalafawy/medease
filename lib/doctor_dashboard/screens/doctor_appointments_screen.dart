import 'package:flutter/material.dart';
import '../widgets/doctor_bottom_bar.dart';
import '../doctor_main_navigation.dart';
import '../../core/theme/app_theme.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final VoidCallback onBack;

  const DoctorAppointmentsScreen({
    super.key,
    required this.appointments,
    required this.onBack,
  });

  // Available days (true = available, false = not available)
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
                Text(
                  'Your Appointment',
                  style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 22),
                ),
                const SizedBox(height: 18),
                // Days bar with edit icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: availableDays[i] ? AppTheme.primaryColor : AppTheme.greyColor.withOpacity(0.3),
                    ),
                    onPressed: availableDays[i]
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Edit slots for ${daysShort[i]}')),
                            );
                          }
                        : null,
                    iconSize: 20,
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
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                // Appointment cards
                ...displayAppointments.map((appt) => Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      appt['patient'] ?? '',
                                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Material(
                                      color: AppTheme.primaryColor.withOpacity(0.07),
                                      shape: const CircleBorder(),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, color: AppTheme.primaryColor, size: 16),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Edit appointment for ${appt['patient']}')),
                                          );
                                        },
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text('Date', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Text(
                                      appt['date'] ?? '',
                                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 24),
                                    Text('Time', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 8),
                                    Text(
                                      appt['time'] ?? '',
                                      style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
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