import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, patients:patient_id(full_name)').order('date', ascending: true);
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
      await Supabase.instance.client
          .from('appointments')
          .update({'status': 'cancelled'})
          .eq('appointment_id', appointmentId);
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
    // {
    //   'patient': 'Menna Ahmed',
    //     'date': '2023-04-22',
    //     'day': 'Saturday',
    //   'time': '16:30 - 18:30',
    //     'status': 'pending',
    //     'message': 'I have a fever and headache.',
    // },
    // {
    //   'patient': 'Rana Mohamed',
    //     'date': '2023-04-24',
    //     'day': 'Monday',
    //   'time': '11:00-16:00',
    //     'status': 'confirmed',
    //     'message': '',
    //   },
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
  
  Color statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.greyColor;
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
                  style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(appt['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText(appt['status']),
                    style: AppTheme.bodyMedium.copyWith(color: statusColor(appt['status']), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(appt['date'] ?? '', style: AppTheme.bodyLarge),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(appt['time'] ?? '', style: AppTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            if ((appt['message'] ?? '').isNotEmpty) ...[
              Text('Message from patient:', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(appt['message'], style: AppTheme.bodyLarge),
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
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirm', style: TextStyle(fontSize: 13)),
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
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Appointment'),
                            content: const Text('Are you sure you want to edit this appointment?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Edit')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          _showEditAppointmentDialog(appt);
                        }
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
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
                            title: const Text('Cancel Appointment'),
                            content: const Text('Are you sure you want to cancel this appointment?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await cancelAppointment(appt['appointment_id']);
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Cancel', style: TextStyle(fontSize: 13)),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: const AssetImage('assets/images/profile_picture.png'),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt['patients']?['full_name'] ?? 'Unknown',
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                color: statusColor(appt['status']),
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor(appt['status']).withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  statusText(appt['status']),
                                  style: AppTheme.bodyMedium.copyWith(color: statusColor(appt['status']), fontWeight: FontWeight.bold),
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
                Text('Select Day', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: daysShort.length,
                    separatorBuilder: (context, i) => const SizedBox(width: 6),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => setState(() => selectedDay = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedDay == i ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          daysShort[i],
                          style: AppTheme.bodyLarge.copyWith(
                            color: selectedDay == i ? Colors.white : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Time', style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Enter time',
                  ),
                  style: AppTheme.bodyLarge,
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
                          textStyle: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor),
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
                            appt['time'] = timeController.text;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: AppTheme.bodyLarge,
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
    );
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
                    onTap: () => setState(() => selectedDayIndex = i),
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
                                                  color: statusColor(appt['status']),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: statusColor(appt['status']).withOpacity(0.13),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(
                                                    statusText(appt['status']),
                                                    style: theme.textTheme.bodyMedium?.copyWith(color: statusColor(appt['status']), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                Row(
                                  children: [
                                            const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                                            const SizedBox(width: 4),
                                    Text(
                                      appt['date'] ?? '',
                                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                                            const SizedBox(width: 4),
                                    Text(
                                      appt['time'] ?? '',
                                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                        if ((appt['message'] ?? '').isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.message, size: 18, color: AppTheme.primaryColor),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  appt['message'],
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