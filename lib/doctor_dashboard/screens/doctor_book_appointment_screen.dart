import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorBookAppointmentScreen extends StatefulWidget {
  const DoctorBookAppointmentScreen({super.key});

  @override
  State<DoctorBookAppointmentScreen> createState() => _DoctorBookAppointmentScreenState();
}

class _DoctorBookAppointmentScreenState extends State<DoctorBookAppointmentScreen> {
  int? selectedSchedule;
  String selectedDay = 'Day';
  String selectedMonth = 'Month';

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  final List<String> schedules = [
    '10:30am - 11:30am',
    '11:30am - 12:30pm',
    '12:30am - 1:30pm',
    '2:30am - 3:30pm',
    '3:30am - 4:30pm',
    '4:30am - 5:30pm',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Doctor's Schedule", style: AppTheme.titleLarge),
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Doctor image at the top
          Container(
            width: double.infinity,
            height: 240,
            color: Colors.white,
            child: Image.asset(
              'assets/images/doctor_photo.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          // Main content
          DraggableScrollableSheet(
            initialChildSize: 0.68,
            minChildSize: 0.68,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -2),
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
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Dr.Ahmed', style: AppTheme.titleLarge),
                        const Spacer(),
                        const Icon(Icons.star, color: Color(0xFFF5B100), size: 20),
                        const SizedBox(width: 4),
                        const Text('4.8', style: AppTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('Neurologist  |  Hospital', style: AppTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.access_time, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 6),
                        Text('10:30am - 5:30pm', style: AppTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Select Date', style: AppTheme.titleLarge),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedDay,
                            items: [selectedDay, ...days].toSet().map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => selectedDay = v ?? 'Day'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: const Color(0xFFF3F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedMonth,
                            items: [selectedMonth, ...months].toSet().map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (v) => setState(() => selectedMonth = v ?? 'Month'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: const Color(0xFFF3F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('Schedules', style: AppTheme.titleLarge),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(schedules.length, (i) => _ScheduleChip(
                        label: schedules[i],
                        selected: selectedSchedule == i,
                        onTap: () => setState(() => selectedSchedule = i),
                      )),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF022E5B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {},
                            child: const Text('Confirm Schedules', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
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

class _ScheduleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ScheduleChip({required this.label, this.selected = false, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : const Color(0xFFF3F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0xFFE5EAF2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
} 