import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorBookAppointmentScreen extends StatefulWidget {
  const DoctorBookAppointmentScreen({super.key});

  @override
  State<DoctorBookAppointmentScreen> createState() => _DoctorBookAppointmentScreenState();
}

class _DoctorBookAppointmentScreenState extends State<DoctorBookAppointmentScreen> {
  int selectedDayIndex = 0;
  late List<DateTime> next7Days;
  Map<int, Map<String, TimeOfDay?>> dayAvailability = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    next7Days = List.generate(7, (i) => now.add(Duration(days: i)));
    for (int i = 0; i < 7; i++) {
      dayAvailability[i] = {'from': null, 'to': null};
    }
  }

  Future<void> _pickTime(int dayIdx, String type) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: dayAvailability[dayIdx]![type] ?? TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        dayAvailability[dayIdx]![type] = picked;
      });
    }
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        title: Text("Doctor's Schedule", style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
        centerTitle: true,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: Stack(
        children: [
          // Doctor image at the top
          Container(
            width: double.infinity,
            height: 240,
            color: AppTheme.backgroundColor,
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
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.04),
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
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text('Dr.Ahmed', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
                        const Spacer(),
                        const Icon(Icons.star, color: Color(0xFFF5B100), size: 20),
                        const SizedBox(width: 4),
                        Text('4.8', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Neurologist  |  Hospital', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text('10:30am - 5:30pm', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Select Day', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: next7Days.length,
                        itemBuilder: (context, idx) {
                          final d = next7Days[idx];
                          final isSelected = idx == selectedDayIndex;
                          return GestureDetector(
                            onTap: () => setState(() => selectedDayIndex = idx),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.bookingDayColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.weekday % 7],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${d.day}/${d.month}",
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.primaryColor,
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
                    const SizedBox(height: 18),
                    Text('Select Available Time', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(selectedDayIndex, 'from'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('From', style: AppTheme.bodyLarge),
                                  Text(_formatTime(dayAvailability[selectedDayIndex]!['from']), style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(selectedDayIndex, 'to'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('To', style: AppTheme.bodyLarge),
                                  Text(_formatTime(dayAvailability[selectedDayIndex]!['to']), style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // TODO: Save dayAvailability to backend or local storage
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Availability saved!')),
                          );
                        },
                        child: Text('Save Availability', style: AppTheme.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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