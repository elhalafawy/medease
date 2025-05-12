import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorBookAppointmentScreen extends StatefulWidget {
  const DoctorBookAppointmentScreen({super.key});

  @override
  State<DoctorBookAppointmentScreen> createState() => _DoctorBookAppointmentScreenState();
}

class _DoctorBookAppointmentScreenState extends State<DoctorBookAppointmentScreen> {
  List<int> selectedDayIndices = [];
  int selectedTimeIndex = -1;
  late List<DateTime> next7Days;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  Set<int> unavailableTimes = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    next7Days = List.generate(7, (i) => now.add(Duration(days: i)));
  }

  List<String> get availableTimes {
    if (fromTime == null || toTime == null) return [];
    
    final List<String> times = [];
    TimeOfDay currentTime = fromTime!;
    
    while (currentTime.hour < toTime!.hour || 
           (currentTime.hour == toTime!.hour && currentTime.minute <= toTime!.minute)) {
      times.add(_formatTime(currentTime));
      currentTime = TimeOfDay(
        hour: currentTime.minute == 30 ? currentTime.hour + 1 : currentTime.hour,
        minute: currentTime.minute == 30 ? 0 : 30,
      );
    }
    
    return times;
  }

  Future<void> _pickTime(int dayIdx, String type) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: fromTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (type == 'from') {
          fromTime = picked;
        } else {
          toTime = picked;
        }
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

  void _resetForm() {
    setState(() {
      selectedDayIndices = [];
      selectedTimeIndex = -1;
      fromTime = null;
      toTime = null;
      unavailableTimes = {};
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/password_success.png',
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Appointments Set Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00264D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your availability has been updated successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00264D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                          final isSelected = selectedDayIndices.contains(idx);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedDayIndices.remove(idx);
                                } else {
                                  selectedDayIndices.add(idx);
                                }
                              });
                            },
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
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: fromTime ?? const TimeOfDay(hour: 9, minute: 0),
                              );
                              if (picked != null) setState(() => fromTime = picked);
                            },
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
                                  const Text('From', style: AppTheme.bodyLarge),
                                  Text(_formatTime(fromTime), style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: toTime ?? const TimeOfDay(hour: 17, minute: 0),
                              );
                              if (picked != null) setState(() => toTime = picked);
                            },
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
                                  const Text('To', style: AppTheme.bodyLarge),
                                  Text(_formatTime(toTime), style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (fromTime != null && toTime != null && selectedDayIndices.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Available Time', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableTimes.length,
                          separatorBuilder: (context, i) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final isUnavailable = unavailableTimes.contains(i);
                            final isSelected = !isUnavailable && selectedTimeIndex == i;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (unavailableTimes.contains(i)) {
                                    unavailableTimes.remove(i);
                                  } else {
                                    unavailableTimes.add(i);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : isUnavailable
                                          ? AppTheme.greyColor.withOpacity(0.2)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : isUnavailable
                                            ? AppTheme.greyColor
                                            : AppTheme.primaryColor.withOpacity(0.15),
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                child: Text(
                                  availableTimes[i],
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : isUnavailable
                                            ? AppTheme.greyColor
                                            : AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showSuccessDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: AppTheme.titleLarge,
                          ),
                          child: const Text('Confirm'),
                        ),
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