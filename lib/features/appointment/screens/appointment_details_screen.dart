import 'package:flutter/material.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

  Future<void> fetchAvailableTimeSlots(String date, StateSetter dialogSetState) async {
    dialogSetState(() {
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
        dialogSetState(() {
          availableTimeSlots = List<Map<String, dynamic>>.from(response);
          isLoadingTimeSlots = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching time slots: $e');
      dialogSetState(() {
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
        builder: (context, setState) {
          final theme = Theme.of(context);
          return Dialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Update Appointment',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Date',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: weekDates.length,
                              itemBuilder: (context, index) {
                                final date = weekDates[index];
                                final isSelected = index == selectedDayIndex;
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectedDayIndex = index;
                                      selectedDate = DateFormat('yyyy-MM-dd').format(date);
                                    });
                                    if (selectedDate != null) {
                                      await fetchAvailableTimeSlots(selectedDate!, setState);
                                      selectedTimeSlotId = null; // Reset selected time slot when date changes
                                    }
                                  },
                                  child: Container(
                                    width: 60,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('EEE').format(date),
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('dd').format(date),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.onSurface,
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
                          Text(
                            'Available Time Slots',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          isLoadingTimeSlots
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                )
                              : availableTimeSlots.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No available slots for this date.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: availableTimeSlots.map((slot) {
                                        final isSelected = selectedTimeSlotId == slot['slot_id'];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedTimeSlotId = slot['slot_id'];
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.surfaceVariant,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.outline.withOpacity(0.5),
                                              ),
                                            ),
                                            child: Text(
                                              formatTimeTo12Hour(slot['time_slot']),
                                              style: theme.textTheme.labelLarge?.copyWith(
                                                color: isSelected
                                                    ? theme.colorScheme.onPrimary
                                                    : theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: selectedTimeSlotId == null
                                  ? null
                                  : () async {
                                      setState(() => isUpdating = true);
                                      try {
                                        await updateAppointment(
                                          appointmentId,
                                          selectedDate!,
                                          selectedTimeSlotId!,
                                        );
                                        CustomSnackBar.show(
                                          context: _scaffoldContext,
                                          message: 'Appointment updated successfully!',
                                        );
                                        Navigator.pop(context);
                                      } catch (e) {
                                        CustomSnackBar.show(
                                          context: _scaffoldContext,
                                          message: 'Failed to update appointment: ${e.toString()}',
                                          isError: true,
                                        );
                                      } finally {
                                        setState(() => isUpdating = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: isUpdating
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Update Appointment',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Appointment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Yes',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface),
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
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              onPressed: _showUpdateDialog,
            ),
          if (widget.appointment['status'] == 'pending' ||
              widget.appointment['status'] == 'confirmed')
            IconButton(
              icon: Icon(Icons.cancel, color: theme.colorScheme.error),
              onPressed: _showCancelDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.surfaceVariant,
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
                                  color: theme.colorScheme.onSurfaceVariant),
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
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildInfoColumn(
                                Icons.calendar_today,
                                'Date',
                                widget.appointment['date']?.toString() ?? 'Mon 4',
                                theme,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoColumn(
                                Icons.access_time,
                                'Time',
                                (() {
                                  final t = widget.appointment['time'];
                                  if (t is String && t.length >= 5) {
                                    final timeStr = t.endsWith(':00') ? t.substring(0,5) : t;
                                    return formatTimeTo12Hour(timeStr);
                                  }
                                  return t ?? '9:00 AM';
                                })(),
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10), // Space between the two cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildInfoColumn(
                                Icons.location_on,
                                'Location',
                                widget.appointment['location'] ?? 'Medical Center',
                                theme,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoColumn(
                                Icons.medical_services_outlined,
                                'Type',
                                ((widget.appointment['type'] ?? 'consultation')
                                  .toString()
                                  .replaceAll('_', ' ')
                                  .split(' ')
                                  .map((word) => word[0].toUpperCase() + word.substring(1))
                                  .join(' ')),
                                theme,
                              ),
                            ),
                          ],
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
                                    widget.appointment['status'] ?? 'pending', theme)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.appointment['status'] ?? 'pending',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _getStatusColor(
                                  widget.appointment['status'] ?? 'pending', theme),
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
                            'Patient Name', patientData?['full_name'] ?? ' ', Icons.person, theme),
                        const Divider(),
                        _buildInfoRow('Phone Number',
                            patientData?['contact_info'] ?? ' ', Icons.phone, theme),
                        const Divider(),
                        _buildInfoRow('Email', patientData?['email'] ?? ' ', Icons.email, theme),
                        const Divider(),
                        _buildInfoRow(
                            'Notes',
                            widget.appointment['notes'] ??
                                'No additional notes', Icons.note, theme),
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

  Widget _buildInfoColumn(IconData icon, String title, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, ThemeData theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String formatTimeTo12Hour(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time; // Invalid format

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = (hour % 12 == 0) ? 12 : hour % 12;

    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }
}
