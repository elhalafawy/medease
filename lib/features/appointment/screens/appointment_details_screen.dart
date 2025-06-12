import 'package:flutter/material.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//TODO: Add patient data to the appointment details screen

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onUpdate;
  final Function(String)? onCancel;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.onBack,
    this.onUpdate,
    this.onCancel,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool isUpdating = false;
  bool isCanceling = false;
  Map<String, dynamic>? appointmentData;
  Map<String, dynamic>? patientData;
  bool isLoading = false;
  late BuildContext _scaffoldContext;
  List<Map<String, dynamic>> availableTimeSlots = [];
  bool isLoadingTimeSlots = false;
  String? selectedDate;
  String? selectedTimeSlotId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldContext = context;
  }

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    final patientId = widget.appointment['patient_id'];
    if (patientId == null) return;
    setState(() => isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('patients')
          .select('*')
          .eq('patient_id', patientId)
          .single();
      setState(() {
        patientData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Failed to fetch patient data: $e');
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Simulate search functionality
    setState(() {
      _isSearching = true;
      _searchResults = [
        {
          'doctorName': 'Dr. Ahmed',
          'specialty': 'Senior Neurologist and Surgeon',
          'date': 'Mon 4',
          'time': '9:00 AM',
          'status': 'ending',
          'imageUrl': 'assets/images/doctor_photo.png',
        },
      ].where((appointment) {
        return appointment['doctorName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            appointment['specialty']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> fetchAvailableTimeSlots(String date) async {
    setState(() {
      isLoadingTimeSlots = true;
      isLoading = true;
    });

    try {
      final response = await Supabase.instance.client
          .from('time_slots_duplicate')
          .select('slot_id, time_slot, status')
          .eq('doctor_id', widget.appointment['doctor_id'])
          .eq('available_date', date)
          .eq('status', 'available')
          .order('time_slot', ascending: true);

      if (response != null) {
        setState(() {
          availableTimeSlots = List<Map<String, dynamic>>.from(response);
          isLoadingTimeSlots = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching time slots: $e');
      setState(() {
        isLoadingTimeSlots = false;
        availableTimeSlots = [];
      });
    }
  }

  Future<void> updateAppointment(
      String appointmentId, String newDate, String newTimeSlotId) async {
    if (appointmentId.isEmpty) {
      throw Exception('Invalid appointment ID');
    }

    try {
      // Get the time slot details
      final timeSlotResponse = await Supabase.instance.client
          .from('time_slots_duplicate')
          .select('time_slot')
          .eq('slot_id', newTimeSlotId)
          .single();

      if (timeSlotResponse == null) {
        throw Exception('Time slot not found');
      }

      // Update the appointment
      await Supabase.instance.client.from('appointments').update({
        'date': newDate,
        'time': timeSlotResponse['time_slot'],
        'time_slot_id': newTimeSlotId,
      }).eq('appointment_id', appointmentId);

      // Update the old time slot to available
      final oldTimeSlotId = widget.appointment['time_slot_id'];
      if (oldTimeSlotId != null) {
        await Supabase.instance.client
            .from('time_slots_duplicate')
            .update({'status': 'available'}).eq('slot_id', oldTimeSlotId);
      }

      // Update the new time slot to booked
      await Supabase.instance.client
          .from('time_slots_duplicate')
          .update({'status': 'booked'}).eq('slot_id', newTimeSlotId);

      if (widget.onUpdate != null) {
        final updatedAppointment =
            Map<String, dynamic>.from(widget.appointment);
        updatedAppointment['date'] = newDate;
        updatedAppointment['time'] = timeSlotResponse['time_slot'];
        updatedAppointment['time_slot_id'] = newTimeSlotId;
        widget.onUpdate!(updatedAppointment);
      }
    } catch (e) {
      print('Failed to update appointment: $e');
      throw e;
    }
  }

  void _showUpdateDialog() {
    int selectedDayIndex = 0;
    int selectedTimeIndex = 0;
    final now = DateTime.now();
    final List<DateTime> weekDates = List.generate(7, (i) => now.add(Duration(days: i)));
    // Define all possible slots for the day (customize as needed)
    final allPossibleSlots = ['9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM'];
    final appointmentId = widget.appointment['appointment_id']?.toString();
    if (appointmentId == null || appointmentId.isEmpty) {
      CustomSnackBar.show(
        context: _scaffoldContext,
        message: 'Invalid appointment ID',
        isError: true,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Update Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            (widget.appointment['imageUrl'] is String &&
                                    widget.appointment['imageUrl'] != null &&
                                    widget.appointment['imageUrl']!.isNotEmpty)
                                ? widget.appointment['imageUrl']
                                : (widget.appointment['image'] is String &&
                                        widget.appointment['image'] != null &&
                                        widget.appointment['image']!.isNotEmpty)
                                    ? widget.appointment['image']
                                    : 'assets/images/doctor_photo.png',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.appointment['doctorName']?.toString() ??
                                    'Dr. Ahmed',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              Text(
                                widget.appointment['specialty'] ??
                                    'Neurologist',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Appointment",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF232B3E)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(weekDates.length, (index) {
                          final isSelected = index == selectedDayIndex;
                          final date = weekDates[index];
                          final dayName = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
                          final dateNum = date.day;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDayIndex = index;
                                final selectedDate = date.toIso8601String().split('T')[0];
                                fetchAvailableTimeSlots(selectedDate);
                                selectedTimeIndex = -1;
                                selectedTimeSlotId = null;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF7DDCFF) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF7DDCFF) : Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: const Color(0xFF7DDCFF).withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))]
                                    : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$dayName $dateNum',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF232B3E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Available Time",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF232B3E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ... existing code ...
// if (isLoadingTimeSlots)
//   const Center(child: CircularProgressIndicator())
// else
                  if (availableTimeSlots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No available time slots for this day'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            List.generate(availableTimeSlots.length, (index) {
                          final slotTime =
                              availableTimeSlots[index]['time_slot'];
                          final availableSlotTimes = availableTimeSlots
                              .map((s) => s['time_slot'])
                              .toSet();
                          final isAvailable =
                              availableSlotTimes.contains(slotTime);
                          final isSelected =
                              isAvailable && selectedTimeIndex == index;
                          return GestureDetector(
                            onTap: isAvailable
                                ? () => setState(() {
                                      isLoadingTimeSlots = false;
                                      isLoading = false;
                                      selectedTimeIndex = index;
                                      selectedTimeSlotId =
                                          availableTimeSlots.firstWhere((s) =>
                                              s['time_slot'] ==
                                              slotTime)['slot_id'];
                                    })
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF5B183)
                                    : isAvailable
                                        ? const Color(0xFFF3F3F3)
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF5B183)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                slotTime is String && slotTime.length >= 5
                                    ? slotTime.substring(0, 5)
                                    : slotTime,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isAvailable
                                          ? const Color(0xFF9C9C9C)
                                          : Colors.grey,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: selectedTimeSlotId == null
                              ? null
                              : () async {
                                  final selectedDate = DateTime(
                                    now.year,
                                    now.month,
                                    now.day + selectedDayIndex,
                                  ).toIso8601String().split('T')[0];
                                  try {
                                    await updateAppointment(
                                      appointmentId,
                                      selectedDate,
                                      selectedTimeSlotId!,
                                    );
                                    if (mounted) {
                                      CustomSnackBar.show(
                                        context: _scaffoldContext,
                                        message:
                                            'Appointment updated successfully',
                                      );
                                      Navigator.pop(
                                          context); // Close the update dialog
                                      Navigator.pop(
                                          context); // Return to schedule screen
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      CustomSnackBar.show(
                                        context: _scaffoldContext,
                                        message: 'Failed to update appointment',
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14375A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cancelAppointment(String appointmentId) async {
    if (appointmentId.isEmpty) {
      throw Exception('Invalid appointment ID');
    }

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
          .update({'status': 'cancelled'}).eq('appointment_id', appointmentId);

      // If slot_id exists, update the slot status to 'available'
      if (appointment != null && appointment['time_slot_id'] != null) {
        final slotId = appointment['time_slot_id'];
        await Supabase.instance.client
            .from('time_slots_duplicate')
            .update({'status': 'available'}).eq('slot_id', slotId);
      }

      if (widget.onUpdate != null) {
        final updatedAppointment =
            Map<String, dynamic>.from(widget.appointment);
        updatedAppointment['status'] = 'cancelled';
        widget.onUpdate!(updatedAppointment);
      }
    } catch (e) {
      print('Failed to cancel appointment: $e');
      throw e; // Re-throw to handle in the UI
    }
  }

  void _showCancelDialog() {
    final appointmentId = widget.appointment['appointment_id']?.toString();
    if (appointmentId == null || appointmentId.isEmpty) {
      CustomSnackBar.show(
        context: _scaffoldContext,
        message: 'Invalid appointment ID',
        isError: true,
      );
      return;
    }

    showDialog(
      context: _scaffoldContext,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await cancelAppointment(appointmentId);
                if (mounted) {
                  CustomSnackBar.show(
                    context: _scaffoldContext,
                    message: 'Appointment cancelled successfully',
                  );
                  Navigator.pop(_scaffoldContext); // Return to schedule screen
                }
              } catch (e) {
                if (mounted) {
                  CustomSnackBar.show(
                    context: _scaffoldContext,
                    message: 'Failed to cancel appointment',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Appointment Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.appointment['status'] == 'pending' ||
              widget.appointment['status'] == 'confirmed')
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: _showUpdateDialog,
            ),
          if (widget.appointment['status'] == 'pending' ||
              widget.appointment['status'] == 'confirmed')
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: _showCancelDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          (widget.appointment['imageUrl'] is String &&
                                  widget.appointment['imageUrl'] != null &&
                                  widget.appointment['imageUrl']!.isNotEmpty)
                              ? widget.appointment['imageUrl']
                              : (widget.appointment['image'] is String &&
                                      widget.appointment['image'] != null &&
                                      widget.appointment['image']!.isNotEmpty)
                                  ? widget.appointment['image']
                                  : 'assets/images/doctor_photo.png',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.appointment['doctorName']?.toString() ??
                                  'Dr. Ahmed',
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface),
                            ),
                            Text(
                              widget.appointment['specialty'] ??
                                  'Senior Neurologist and Surgeon',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn(
                          Icons.calendar_today,
                          'Date',
                          widget.appointment['date']?.toString() ?? 'Mon 4',
                        ),
                        _buildInfoColumn(
                          Icons.access_time,
                          'Time',
                          (() {
                            final t = widget.appointment['time'];
                            if (t is String && t.length >= 5) {
                              // If format is HH:mm:00, show HH:mm
                              return t.endsWith(':00') ? t.substring(0,5) : t;
                            }
                            return t ?? '9:00 AM';
                          })(),
                        ),
                        _buildInfoColumn(
                          Icons.location_on,
                          'Location',
                          widget.appointment['location'] ?? 'Medical Center',
                        ),
                        _buildInfoColumn(
                          Icons.medical_services_outlined,
                          'Type',
                          ((widget.appointment['type'] ?? 'consultation')
                            .toString()
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
                            .join(' ')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                                    widget.appointment['status'] ?? 'pending')
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.appointment['status'] ?? 'pending',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getStatusColor(
                                  widget.appointment['status'] ?? 'pending'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (widget.appointment['status'] == 'pending' ||
                            widget.appointment['status'] == 'confirmed')
                          ElevatedButton(
                            onPressed: _showUpdateDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Update'),
                          ),
                        if (widget.appointment['status'] == 'pending' ||
                            widget.appointment['status'] == 'confirmed')
                          const SizedBox(width: 6),
                        if (widget.appointment['status'] == 'pending' ||
                            widget.appointment['status'] == 'confirmed')
                          ElevatedButton(
                            onPressed: _showCancelDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Additional Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            'Patient Name', patientData?['full_name'] ?? ' '),
                        const Divider(),
                        _buildInfoRow('Phone Number',
                            patientData?['contact_info'] ?? ' '),
                        const Divider(),
                        _buildInfoRow('Email', patientData?['email'] ?? ' '),
                        const Divider(),
                        _buildInfoRow(
                            'Notes',
                            widget.appointment['notes'] ??
                                'No additional notes'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
