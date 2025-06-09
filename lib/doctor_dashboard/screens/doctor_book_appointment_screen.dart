// TODO: fix the issue where start time can not be later and end time can not be earlier

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorBookAppointmentScreen extends StatefulWidget {
  const DoctorBookAppointmentScreen({super.key});

  @override
  State<DoctorBookAppointmentScreen> createState() =>
      _DoctorBookAppointmentScreenState();
}

class _DoctorBookAppointmentScreenState
    extends State<DoctorBookAppointmentScreen> {
  List<int> selectedDayIndices = [];
  int selectedTimeIndex = -1;
  late List<DateTime> next7Days;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  Set<int> unavailableTimes = {};
  List<Map<String, dynamic>> confirmedAppointments = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    next7Days = List.generate(7, (i) => now.add(Duration(days: i)));
    loadAppointments(); // Load appointments when screen initializes
  }

  Future<void> loadAppointments() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('time_slots_duplicate')
          .select()
          .eq('doctor_id', 'b55f005f-3185-4fa3-9098-2179e0751621')
          .eq('status', 'available')
          .order('available_date', ascending: true)
          .order('time_slot', ascending: true);

      if (response != null && response is List) {
        // Group slots by date
        Map<String, List<Map<String, dynamic>>> groupedSlots = {};
        
        for (var slot in response) {
          try {
            // Ensure slot is a Map
            if (slot is! Map<String, dynamic>) {
              print('Invalid slot format: $slot');
              continue;
            }

            // Add null checks for required fields with type checking
            final availableDate = slot['available_date'];
            final timeSlot = slot['time_slot'];
            final slotId = slot['slot_id'];

            if (availableDate == null || timeSlot == null || slotId == null) {
              print('Missing required fields in slot: $slot');
              continue;
            }

            // Ensure fields are strings
            if (availableDate is! String || timeSlot is! String) {
              print('Invalid field types in slot: $slot');
              continue;
            }

            // Parse date with error handling
            DateTime? date;
            try {
              date = DateTime.parse(availableDate);
            } catch (e) {
              print('Invalid date format: $availableDate');
              continue;
            }

            final dateKey = date.toIso8601String().split('T')[0];
            
            // Validate time slot format
            if (!timeSlot.contains(':')) {
              print('Invalid time format in slot: $timeSlot');
              continue;
            }

            final timeParts = timeSlot.split(':');
            if (timeParts.length < 2) {
              print('Invalid time format in slot: $timeSlot');
              continue;
            }

            // Parse hours and minutes with error handling
            int? hour = int.tryParse(timeParts[0]);
            int? minute = int.tryParse(timeParts[1]);
            
            if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
              print('Invalid time values in slot: $timeSlot');
              continue;
            }

            final time = TimeOfDay(hour: hour, minute: minute);

            if (!groupedSlots.containsKey(dateKey)) {
              groupedSlots[dateKey] = [];
            }

            groupedSlots[dateKey]!.add({
              'time': time,
              'slot_id': slotId.toString(),
            });
          } catch (e) {
            print('Error parsing slot: $e');
            continue;
          }
        }

        // Convert grouped slots to the format expected by the UI
        setState(() {
          confirmedAppointments = groupedSlots.entries.map((entry) {
            try {
              final date = DateTime.parse(entry.key);
              final slots = entry.value;
              
              // Sort slots by time
              slots.sort((a, b) {
                final timeA = a['time'] as TimeOfDay;
                final timeB = b['time'] as TimeOfDay;
                if (timeA.hour != timeB.hour) {
                  return timeA.hour.compareTo(timeB.hour);
                }
                return timeA.minute.compareTo(timeB.minute);
              });

              // Ensure we have slots before accessing first and last
              if (slots.isEmpty) {
                return null;
              }

              return {
                'day': date,
                'slots': slots,
                'start_time': slots.first['time'] as TimeOfDay,
                'end_time': slots.last['time'] as TimeOfDay,
                'slot_ids': slots.map((s) => s['slot_id'] as String).toList(),
              };
            } catch (e) {
              print('Error processing date entry: $e');
              return null;
            }
          })
          .where((appt) => appt != null) // Filter out null entries
          .cast<Map<String, dynamic>>()
          .toList();
        });
      } else {
        setState(() {
          confirmedAppointments = [];
        });
      }
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        confirmedAppointments = [];
      });
    }
  }

  List<String> get availableTimes {
    if (fromTime == null || toTime == null) return [];

    final List<String> times = [];
    TimeOfDay currentTime = fromTime!;

    while (currentTime.hour < toTime!.hour ||
        (currentTime.hour == toTime!.hour &&
            currentTime.minute <= toTime!.minute)) {
      times.add(_formatTime(currentTime));
      currentTime = TimeOfDay(
        hour:
            currentTime.minute == 30 ? currentTime.hour + 1 : currentTime.hour,
        minute: currentTime.minute == 30 ? 0 : 30,
      );
    }

    return times;
  }

  Future<void> _pickTime(int dayIdx, String type) async {
    final initialTime = type == 'from' 
        ? (fromTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (toTime ?? const TimeOfDay(hour: 17, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (type == 'from') {
          fromTime = picked;
          // If end time is before or equal to new start time, reset it
          if (toTime != null && 
              (toTime!.hour < picked.hour || 
               (toTime!.hour == picked.hour && toTime!.minute <= picked.minute))) {
            toTime = null;
          }
        } else {
          toTime = picked;
          // If start time is after or equal to new end time, reset it
          if (fromTime != null && 
              (fromTime!.hour > picked.hour || 
               (fromTime!.hour == picked.hour && fromTime!.minute >= picked.minute))) {
            fromTime = null;
          }
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
                  setState(() {
                    for (var idx in selectedDayIndices) {
                      confirmedAppointments.add({
                        'day': next7Days[idx],
                        'from': fromTime,
                        'to': toTime,
                      });
                    }
                  });
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

  // Helper to generate 30-minute slots between start and end time
  List<TimeOfDay> generateTimeSlots(TimeOfDay start, TimeOfDay end) {
    List<TimeOfDay> slots = [];
    
    // Convert to minutes for easier comparison
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;
    
    // If end time is before or equal to start time, return empty list
    if (endMinutes <= startMinutes) {
      print('End time must be after start time');
      return slots;
    }

    TimeOfDay current = start;
    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute <= end.minute)) {
      slots.add(current);
      int newMinute = current.minute + 30;
      int newHour = current.hour;
      if (newMinute >= 60) {
        newHour += 1;
        newMinute -= 60;
      }
      current = TimeOfDay(hour: newHour, minute: newMinute);
    }
    return slots;
  }

  // Use this in your addTimeSlot logic:
  Future<void> addTimeSlots({
    required String doctorId,
    required DateTime availableDate,
    required TimeOfDay fromTime,
    required TimeOfDay toTime,
    String status = 'available',
    String? recurringRule,
  }) async {
    final supabase = Supabase.instance.client;
    List<TimeOfDay> slots = generateTimeSlots(fromTime, toTime);
    for (final slot in slots) {
      final timeStr = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00';
      await supabase.from('time_slots_duplicate').insert({
        'doctor_id': doctorId,
        'available_date': availableDate.toIso8601String().split('T')[0],
        'time_slot': timeStr,
        'status': status,
        'recurring_rule': recurringRule,
      });
    }
  }

  Future<void> deleteAppointment(List<String> slotIds) async {
    final supabase = Supabase.instance.client;
    try {
      for (final slotId in slotIds) {
        await supabase
            .from('time_slots_duplicate')
            .delete()
            .eq('slot_id', slotId);
      }

      // Refresh the appointments list after deletion
      await loadAppointments();
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  Future<void> updateAppointment({
    required List<String> slotIds,
    required DateTime newDate,
    required TimeOfDay newStartTime,
    required TimeOfDay newEndTime,
  }) async {
    final supabase = Supabase.instance.client;
    try {
      // Validate time range
      int startMinutes = newStartTime.hour * 60 + newStartTime.minute;
      int endMinutes = newEndTime.hour * 60 + newEndTime.minute;
      
      if (endMinutes <= startMinutes) {
        print('Invalid time range: End time must be after start time');
        return;
      }

      // Get all slots for the date
      final existingSlots = await supabase
          .from('time_slots_duplicate')
          .select()
          .eq('doctor_id', 'b55f005f-3185-4fa3-9098-2179e0751621')
          .eq('available_date', newDate.toIso8601String().split('T')[0]);

      // Create a set of existing time slots for quick lookup
      final existingTimeSlots = <String>{};
      for (var slot in existingSlots) {
        existingTimeSlots.add(slot['time_slot'] as String);
      }

      // Delete slots outside the new time range
      for (var slot in existingSlots) {
        final timeSlot = slot['time_slot'] as String;
        final timeParts = timeSlot.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final slotMinutes = hour * 60 + minute;

          if (slotMinutes < startMinutes || slotMinutes > endMinutes) {
            await supabase
                .from('time_slots_duplicate')
                .delete()
                .eq('slot_id', slot['slot_id']);
          }
        }
      }

      // Generate new time slots
      List<TimeOfDay> newSlots = generateTimeSlots(newStartTime, newEndTime);
      
      if (newSlots.isEmpty) {
        print('No valid time slots generated');
        return;
      }

      // Create new slots for the new date, avoiding duplicates
      for (final slot in newSlots) {
        final timeStr = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00';
        
        // Only insert if the time slot doesn't already exist
        if (!existingTimeSlots.contains(timeStr)) {
          await supabase.from('time_slots_duplicate').insert({
            'doctor_id': 'b55f005f-3185-4fa3-9098-2179e0751621',
            'available_date': newDate.toIso8601String().split('T')[0],
            'time_slot': timeStr,
            'status': 'available',
          });
        }
      }

      // Refresh the appointments list after update
      await loadAppointments();
    } catch (e) {
      print('Error updating appointment: $e');
      await loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Doctor's Schedule",
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.primary)),
        centerTitle: true,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            color: theme.scaffoldBackgroundColor,
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
                color: theme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                    Row(
                      children: [
                        Text('Dr.Ahmed',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                        const Spacer(),
                        const Icon(Icons.star,
                            color: Color(0xFFF5B100), size: 20),
                        const SizedBox(width: 4),
                        Text('4.8',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Neurologist  |  Hospital',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 6),
                        Text('10:30am - 5:30pm',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: theme.colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Select Day',
                        style: AppTheme.titleLarge
                            .copyWith(color: AppTheme.primaryColor)),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7DDCFF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.15)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    [
                                      "Sun",
                                      "Mon",
                                      "Tue",
                                      "Wed",
                                      "Thu",
                                      "Fri",
                                      "Sat"
                                    ][d.weekday % 7],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${d.day}/${d.month}",
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.primary,
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
                            onTap: () => _pickTime(0, 'from'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('From',
                                      style: theme.textTheme.bodyLarge),
                                  Text(_formatTime(fromTime),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(0, 'to'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('To', style: theme.textTheme.bodyLarge),
                                  Text(_formatTime(toTime),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (fromTime != null &&
                        toTime != null &&
                        selectedDayIndices.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Available Time',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableTimes.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final isUnavailable = unavailableTimes.contains(i);
                            final isSelected =
                                !isUnavailable && selectedTimeIndex == i;
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : isUnavailable
                                          ? theme.colorScheme.primary
                                              .withOpacity(0.2)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : isUnavailable
                                            ? theme.colorScheme.surface
                                            : theme.colorScheme.primary
                                                .withOpacity(0.15),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2))
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  availableTimes[i],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : isUnavailable
                                            ? theme.colorScheme.surface
                                            : theme.colorScheme.primary,
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
                          onPressed: () async {
                            String doctorId =
                                'b55f005f-3185-4fa3-9098-2179e0751621';
                            if (selectedDayIndices.isNotEmpty &&
                                fromTime != null &&
                                toTime != null) {
                              for (var idx in selectedDayIndices) {
                                final date = next7Days[idx];
                                final dateStr = date.toIso8601String().split('T')[0];

                                // Fetch all existing slots for the day
                                final existingSlots = await Supabase.instance.client
                                    .from('time_slots_duplicate')
                                    .select()
                                    .eq('doctor_id', doctorId)
                                    .eq('available_date', dateStr)
                                    .eq('status', 'available');

                                // Convert fromTime and toTime to minutes for comparison
                                final startMinutes = fromTime!.hour * 60 + fromTime!.minute;
                                final endMinutes = toTime!.hour * 60 + toTime!.minute;

                                // Delete slots outside the new range
                                for (var slot in existingSlots) {
                                  final timeSlot = slot['time_slot'] as String;
                                  final timeParts = timeSlot.split(':');
                                  if (timeParts.length >= 2) {
                                    final hour = int.parse(timeParts[0]);
                                    final minute = int.parse(timeParts[1]);
                                    final slotMinutes = hour * 60 + minute;
                                    if (slotMinutes < startMinutes || slotMinutes > endMinutes) {
                                      await Supabase.instance.client
                                          .from('time_slots_duplicate')
                                          .delete()
                                          .eq('slot_id', slot['slot_id']);
                                    }
                                  }
                                }

                                // Create a set of existing time slots (after deletion)
                                final updatedSlots = await Supabase.instance.client
                                    .from('time_slots_duplicate')
                                    .select()
                                    .eq('doctor_id', doctorId)
                                    .eq('available_date', dateStr)
                                    .eq('status', 'available');
                                final existingTimeSlots = <String>{};
                                for (var slot in updatedSlots) {
                                  existingTimeSlots.add(slot['time_slot'] as String);
                                }

                                // Generate new slots
                                List<TimeOfDay> newSlots = generateTimeSlots(fromTime!, toTime!);

                                // Only add slots that don't exist
                                for (final slot in newSlots) {
                                  final timeStr = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00';
                                  if (!existingTimeSlots.contains(timeStr)) {
                                    await addTimeSlots(
                                      doctorId: doctorId,
                                      availableDate: date,
                                      fromTime: slot,
                                      toTime: TimeOfDay(
                                        hour: slot.hour,
                                        minute: slot.minute + 30 > 59 ? 0 : slot.minute + 30
                                      ),
                                    );
                                  }
                                }
                              }
                              await loadAppointments();
                              _showSuccessDialog();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: theme.textTheme.titleLarge,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ),
                    ),
                    if (confirmedAppointments.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Confirmed Days:',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: confirmedAppointments.length,
                        itemBuilder: (context, idx) {
                          if (idx >= confirmedAppointments.length)
                            return const SizedBox.shrink();

                          final appt = confirmedAppointments[idx];
                          final day = appt['day'] as DateTime;
                          final startTime = appt['start_time'] as TimeOfDay?;
                          final endTime = appt['end_time'] as TimeOfDay?;
                          final slotIds = appt['slot_ids'] as List<String>?;

                          // Skip if we don't have valid time data
                          if (startTime == null || endTime == null || slotIds == null) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                '${[
                                  "Sun",
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat"
                                ][day.weekday % 7]} - ${day.day}/${day.month}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'From: ${startTime.format(context)}  To: ${endTime.format(context)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      if (idx < confirmedAppointments.length) {
                                        final oldDate = day;
                                        final oldStartTime = startTime;
                                        final oldEndTime = endTime;

                                        // Find the closest day in next7Days
                                        final dayIndex = next7Days.indexWhere(
                                            (d) =>
                                                d.year == day.year &&
                                                d.month == day.month &&
                                                d.day == day.day);

                                        if (dayIndex != -1) {
                                          // Set the time range for editing
                                          setState(() {
                                            selectedDayIndices = [dayIndex];
                                            fromTime = oldStartTime;
                                            toTime = oldEndTime;
                                          });

                                          // Update all slots for the day
                                          await updateAppointment(
                                            slotIds: slotIds,
                                            newDate: next7Days[dayIndex],
                                            newStartTime: fromTime!,
                                            newEndTime: toTime!,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      if (idx < confirmedAppointments.length) {
                                        await deleteAppointment(slotIds);
                                        setState(() {
                                          if (idx < confirmedAppointments.length) {
                                            confirmedAppointments.removeAt(idx);
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
