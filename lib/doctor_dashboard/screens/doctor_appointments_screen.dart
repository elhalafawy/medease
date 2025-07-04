// TODO: fix a bug where the time slots are not updated when the day is changed unless we double click on the day

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final VoidCallback onBack;

  const DoctorAppointmentsScreen({
    super.key,
    required this.appointments,
    required this.onBack,
  });

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  int selectedDayIndex = 0;
  final List<String> daysShort = const ['All', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  final List<String> daysFull = const ['All', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  String? _error;
  int selectedTimeIndex = 0;
  bool loadingSlots = true;
  List<Map<String, dynamic>> availableTimes = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    fetchtimeSlots("b55f005f-3185-4fa3-9098-2179e0751621", dateStr);
  }

  Future<void> fetchtimeSlots(String doctorId, String date) async {
    setState(() {
      loadingSlots = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('time_slots_duplicate')
          .select('*')
          .eq('doctor_id', doctorId)
          .eq('available_date', date)
          .eq('status', 'available')
          .order('time_slot', ascending: true);

      // Clear existing slots before adding new ones
      setState(() {
        availableTimes = [];
        // Convert response to list and ensure no duplicates
        final uniqueSlots = <Map<String, dynamic>>[];
        final seenSlots = <String>{};
        
        for (var slot in response) {
          final timeSlot = slot['time_slot'] as String?;
          if (timeSlot != null && !seenSlots.contains(timeSlot)) {
            seenSlots.add(timeSlot);
            uniqueSlots.add(slot);
          }
        }
        
        availableTimes = uniqueSlots;
        loadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load time slots';
        loadingSlots = false;
      });
    }
  }

  Future<void> updateAppointmentTimeSlot({
    required String appointmentId,
    required String newTimeSlotId,
    required String oldTimeSlotId,
    required String newTime,
    required String newDate,
  }) async {
    try {
      // 1. Update the appointment with the new time and time_slot_id
      await Supabase.instance.client
          .from('appointments')
          .update({
            'time': newTime,
            'time_slot_id': newTimeSlotId,
            'date': newDate,
          })
          .eq('appointment_id', appointmentId);

      // 2. Mark the old time slot as available
      await Supabase.instance.client
          .from('time_slots_duplicate')
          .update({'status': 'available'})
          .eq('slot_id', oldTimeSlotId);

      // 3. Mark the new time slot as booked
      await Supabase.instance.client
          .from('time_slots_duplicate')
          .update({'status': 'booked'})
          .eq('slot_id', newTimeSlotId);

      // Refresh both appointments and time slots
      await fetchAppointments();
      await fetchtimeSlots("b55f005f-3185-4fa3-9098-2179e0751621", newDate);
    } catch (e) {
      setState(() {
        _error = 'Failed to update appointment time slot';
      });
    }
  }

  Future<void> fetchAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, patients:patient_id(full_name)').order('date', ascending: true).order("time", ascending: true);
          // print(response);
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments';
        _loading = false;
      });
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await Supabase.instance.client
          .from('appointments')
          .update({
            'doctor_confirmed': true,
            'status': 'confirmed'
          })
          .eq('appointment_id', appointmentId);
      await fetchAppointments();
    } catch (e) {
      print('Failed to confirm appointment: $e');
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      // Fetch the appointment to get the slot_id
      final appointment = await Supabase.instance.client
          .from('appointments')
          .select('time_slot_id')
          .eq('appointment_id', appointmentId)
          .single();

      // Cancel the appointment
      await Supabase.instance.client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('appointment_id', appointmentId);

      // If slot_id exists, update the slot status to 'available'
      if (appointment != null && appointment['time_slot_id'] != null) {
        final slotId = appointment['time_slot_id'];
        await Supabase.instance.client
            .from('time_slots_duplicate')
            .update({'status': 'available'})
            .eq('slot_id', slotId);
      }

      // Optionally refresh appointments
      await fetchAppointments();
    } catch (e) {
      // Handle error (show a snackbar, etc.)
      print('Failed to cancel appointment: $e');
    }
  }

  // Example data with status and message
  List<Map<String, dynamic>> get displayAppointments {
    final allAppointments = _appointments.isEmpty ? [

      {
        'patient': 'Ali Hassan',
        'date': '2023-04-25',
        'day': 'Tuesday',
        'time': '10:00-12:00',
        'status': 'cancelled',
        'message': 'Please confirm if you are available.',
      },
    ] : _appointments;
    if (selectedDayIndex == 0) {
      return allAppointments;
    } else {
      // Adjusting weekday comparison: DateTime.sunday is 7, Monday is 1
      // selectedDayIndex 1 is Sunday, 2 is Monday...
      final selectedWeekday = selectedDayIndex == 1 ? 7 : selectedDayIndex - 1; // Map selectedDayIndex to DateTime.weekday
      return allAppointments.where((appt) {
        try {
          final appointmentDate = DateTime.parse(appt['date']);
          return appointmentDate.weekday == selectedWeekday;
        } catch (e) {
          // Handle potential parsing errors, maybe skip this appointment
          print('Error parsing appointment date: ${appt['date']} - $e');
          return false;
        }
      }).toList();
    }
  }
  
  Color statusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return theme.colorScheme.primary;
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String statusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return "Completed";
      default:
        return 'Unknown';
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appt) {
    // print(appt['notes']);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appt['patients']?['full_name'] ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(context, appt['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText(appt['status']),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor(context, appt['status']), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.medical_services_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  ((appt['type'] ?? 'consultation').toString().replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ')),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 0.3,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    decoration: TextDecoration.none,
                    decorationColor: const Color(0xFF3C4A59),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    appt['date'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    (() {
                      final t = appt['time'];
                      if (t is String && t.length >= 5) {
                        final timeStr = t.endsWith(':00') ? t.substring(0,5) : t;
                        return formatTimeTo12Hour(timeStr);
                      }
                      return t ?? '';
                    })(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if ((appt['notes']).isNotEmpty) ...[
              Text('Message from patient:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(appt['notes'], style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: appt['status'] == 'confirmed' ? null : () async {
                        await confirmAppointment(appt['appointment_id']);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.check, size: 18),
                      label: Text('Confirm', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        minimumSize: const Size(0, 38),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        fetchtimeSlots("b55f005f-3185-4fa3-9098-2179e0751621", appt['date']);
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Edit Appointment'),
                            content: Text('Are you sure you want to edit this appointment?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Edit')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          _showEditAppointmentDialog(appt);
                        }
                      },
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        minimumSize: const Size(0, 38),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Cancel Appointment'),
                            content: Text('Are you sure you want to cancel this appointment?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes, Cancel')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await cancelAppointment(appt['appointment_id']);
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(Icons.cancel, size: 18),
                      label: Text('Cancel', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        minimumSize: const Size(0, 38),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAppointmentDialog(Map<String, dynamic> appt) {
    final List<String> days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final List<String> daysShort = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    int selectedDay = days.indexOf(appt['day'] ?? 'Sunday');
    final TextEditingController timeController = TextEditingController(text: appt['time'] ?? '');
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: const AssetImage('assets/images/profile_picture.png'),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt['patients']?['full_name'] ?? 'Unknown',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.medical_services_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    ((appt['type'] ?? 'consultation').toString().replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ')),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      letterSpacing: 0.3,
                                      height: 1.4,
                                      leadingDistribution: TextLeadingDistribution.even,
                                      decoration: TextDecoration.none,
                                      decorationColor: const Color(0xFF3C4A59),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    appt['status'] == 'confirmed'
                                        ? Icons.check_circle
                                        : appt['status'] == 'pending'
                                            ? Icons.hourglass_top
                                            : Icons.cancel,
                                    color: statusColor(context, appt['status']),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor(context, appt['status']).withOpacity(0.13),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      statusText(appt['status']),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: statusColor(context, appt['status']), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Select Day', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysShort.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 6),
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () async {
                            setState(() {
                              selectedDay = i;
                              loadingSlots = true;
                            });
                            DateTime today = DateTime.now();
                            int currentWeekday = today.weekday; // 1 (Mon) - 7 (Sun)
                            int targetWeekday = selectedDay == 0 ? 7 : selectedDay; // 1 (Mon) - 7 (Sun)
                            int daysToAdd = (targetWeekday - currentWeekday) % 7;
                            if (daysToAdd < 0) daysToAdd += 7;
                            DateTime newDate = today.add(Duration(days: daysToAdd));
                            String dateStr = "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
                            await fetchtimeSlots("b55f005f-3185-4fa3-9098-2179e0751621", dateStr);
                            setState(() {
                              loadingSlots = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: selectedDay == i ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: Text(
                              daysShort[i],
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: selectedDay == i ? Colors.white : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('Time', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    loadingSlots
                      ? const Center(child: CircularProgressIndicator())
                      : availableTimes.isEmpty
                        ? const Text('No available slots for this day.')
                        : SizedBox(
                            height: 220, // Adjust height as needed
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, // Three columns
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 2.5, // Adjust for pill shape
                              ),
                              itemCount: availableTimes.length,
                              itemBuilder: (context, index) {
                                final isSelected = index == selectedTimeIndex;
                                return GestureDetector(
                                  onTap: () => setState(() => selectedTimeIndex = index),
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: Text(
                                      (() {
                                        final t = availableTimes[index]['time_slot'];
                                        if (t is String && t.length >= 5) {
                                          final timeStr = t.endsWith(':00') ? t.substring(0,5) : t;
                                          return formatTimeTo12Hour(timeStr);
                                        }
                                        return t ?? 'N/A';
                                      })(),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                appt['day'] = days[selectedDay];
                                // Calculate the proper date string for the selected day
                                DateTime today = DateTime.now();
                                int currentWeekday = today.weekday; // 1 (Mon) - 7 (Sun)
                                int targetWeekday = selectedDay == 0 ? 7 : selectedDay; // 1 (Mon) - 7 (Sun)
                                int daysToAdd = (targetWeekday - currentWeekday) % 7;
                                if (daysToAdd < 0) daysToAdd += 7;
                                DateTime newDate = today.add(Duration(days: daysToAdd));
                                String formattedDate = "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
                                
                                // Ensure all values are strings
                                String appointmentId = appt['appointment_id'].toString();
                                String newTimeSlotId = availableTimes[selectedTimeIndex]['slot_id'].toString();
                                String oldTimeSlotId = appt['time_slot_id'].toString();
                                String newTime = availableTimes[selectedTimeIndex]['time_slot'].toString();
                                
                                updateAppointmentTimeSlot(
                                  appointmentId: appointmentId,
                                  newTimeSlotId: newTimeSlotId,
                                  oldTimeSlotId: oldTimeSlotId,
                                  newTime: newTime,
                                  newDate: formattedDate
                                );
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: Theme.of(context).textTheme.bodyLarge,
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getDateStrForSelectedDay(int selectedDayIndex) {
    DateTime today = DateTime.now();
    int currentWeekday = today.weekday; // 1 (Mon) - 7 (Sun)
    int targetWeekday = selectedDayIndex == 0 ? 7 : selectedDayIndex; // 1 (Mon) - 7 (Sun)
    int daysToAdd = (targetWeekday - currentWeekday) % 7;
    if (daysToAdd < 0) daysToAdd += 7;
    DateTime newDate = today.add(Duration(days: daysToAdd));
    return "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
  }

  // Add this method to handle day selection
  void _handleDaySelection(int index) {
    setState(() {
      selectedDayIndex = index;
      // Fetch time slots for the selected day
      final dateStr = getDateStrForSelectedDay(index);
      fetchtimeSlots("b55f005f-3185-4fa3-9098-2179e0751621", dateStr);
    });
  }

  // Helper to format time to 12-hour with AM/PM
  String formatTimeTo12Hour(String time) {
    try {
      // Accepts 'HH:mm' or 'HH:mm:00'
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final dt = DateTime(0, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    return SafeArea(
      child: Container(
        color: theme.scaffoldBackgroundColor,
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Your Appointment',
                  style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const SizedBox(height: 18),
              // Days selector
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: daysShort.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => _handleDaySelection(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedDayIndex == i ? theme.colorScheme.primary : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.primary.withOpacity(selectedDayIndex == i ? 0 : 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          daysShort[i],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: selectedDayIndex == i ? Colors.white : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ),
                const SizedBox(height: 24),
              Expanded(
                child: displayAppointments.isEmpty
                    ? Center(
                        child: Text('No appointments for this day.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
                      )
                    : ListView.builder(
                        itemCount: displayAppointments.length,
                        itemBuilder: (context, idx) {
                          final appt = displayAppointments[idx];
                          return GestureDetector(
                            onTap: () => _showAppointmentDetails(appt),
                            child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.13), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: const AssetImage('assets/images/profile_picture.png'),
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                            Flexible(
                                              child: Text(
                                      appt['patients']?['full_name'] ?? 'Unknown',
                                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  appt['status'] == 'confirmed'
                                                      ? Icons.check_circle
                                                      : appt['status'] == 'pending'
                                                          ? Icons.hourglass_top
                                                          : Icons.cancel,
                                                  color: statusColor(context, appt['status']),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor(context, appt['status']).withOpacity(0.13),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    statusText(appt['status']),
                                                    style: theme.textTheme.bodyMedium?.copyWith(color: statusColor(context, appt['status']), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        appt['date'] ?? '',
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        (() {
                                          final t = appt['time'];
                                          if (t is String && t.length >= 5) {
                                            final timeStr = t.endsWith(':00') ? t.substring(0,5) : t;
                                            return formatTimeTo12Hour(timeStr);
                                          }
                                          return t ?? '';
                                        })(),
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.medical_services_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        ((appt['type'] ?? 'consultation').toString().replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ')),
                                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                        if ((appt['notes'] ?? '').isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.message, size: 18, color: Theme.of(context).colorScheme.primary),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  appt['notes'],
                                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                 
                                              ),
                                            ],
                                          ),
                                        ],
                              ],
                            ),
                          ),
                        ],
                      ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 