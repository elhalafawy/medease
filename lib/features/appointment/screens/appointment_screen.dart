import 'package:flutter/material.dart';
import 'package:medease/features/appointment/doctor_Patient_Notes_Screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/utils/navigation_wrapper.dart';
import '../../../core/theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  final Map<String, dynamic>? doctor;
  const AppointmentScreen({
    super.key,
    this.doctor,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int selectedDayIndex = 0;
  int selectedTimeIndex = 0;
  bool isBooking = false;
  int notesCount = 0;
  String userNote = "";
  String appointmentType = 'consultation';

  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  List<String> dates = []; // Make dates list dynamic
  final List<dynamic> times = ["9:30" , "10:30" , "11:30" , "12:30" , "13:30"];

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> 
  availableTimeSlots = [];
  bool loadingSlots = false;

  @override
  void initState() {
    super.initState();
    _generateDates(); // Generate dates dynamically
    fetchAvailableTimeSlots();
  }

  void _generateDates() {
    final today = DateTime.now();
    dates.clear(); // Clear existing dates
    for (int i = 0; i < 7; i++) { // Generate next 7 days
      final date = today.add(Duration(days: i));
      dates.add("${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
    }
  }

  // // Helper to generate 30-minute slots between start and end time
  // List<String> generateTimeSlots(String startTime, String endTime) {
  //   List<String> slots = [];
  //   TimeOfDay start = TimeOfDay(
  //     hour: int.parse(startTime.split(":")[0]),
  //     minute: int.parse(startTime.split(":")[1]),
  //   );
  //   TimeOfDay end = TimeOfDay(
  //     hour: int.parse(endTime.split(":")[0]),
  //     minute: int.parse(endTime.split(":")[1]),
  //   );
  //   TimeOfDay current = start;
  //   while (current.hour < end.hour || (current.hour == end.hour && current.minute < end.minute)) {
  //     final hourStr = current.hour.toString().padLeft(2, '0');
  //     final minStr = current.minute.toString().padLeft(2, '0');
  //     slots.add("$hourStr:$minStr");
  //     int newMinute = current.minute + 30;
  //     int newHour = current.hour;
  //     if (newMinute >= 60) {
  //       newHour += 1;
  //       newMinute -= 60;
  //     }
  //     current = TimeOfDay(hour: newHour, minute: newMinute);
  //   }
  //   return slots;
  // }

  // Helper to generate 30-minute slots between start and end time
List<TimeOfDay> generateTimeSlots(TimeOfDay start, TimeOfDay end) {
  List<TimeOfDay> slots = [];
  TimeOfDay current = start;
  while (current.hour < end.hour || (current.hour == end.hour && current.minute < end.minute)) {
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
    final slotStr = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}:00';
    await supabase.from('time_slots_duplicate').insert({
      'doctor_id': doctorId,
      'available_date': availableDate.toIso8601String().split('T')[0], // 'YYYY-MM-DD'
      'time_slot': slotStr,
      'status': status,
      'recurring_rule': recurringRule,
    });
  }
}

  Future<void> fetchAvailableTimeSlots() async {
    setState(() {
      loadingSlots = true;
      availableTimeSlots = [];
    });

    const doctorId = "b55f005f-3185-4fa3-9098-2179e0751621"; // or widget.doctor?['id']
    final selectedDate = dates[selectedDayIndex];
    // Fetch slots from Supabase
    final slots = await supabase
        .from('time_slots_duplicate')
        .select("doctor_id, available_date, time_slot, status")
        .eq('doctor_id', doctorId)
        .eq('available_date', selectedDate)
        .eq('status', 'available')
        .order('time_slot', ascending: true);
    setState(() {
      loadingSlots = false;
      availableTimeSlots = (slots as List?)?.cast<Map<String, dynamic>>() ?? [];
      // selectedTimeIndex = 0;
      times.clear();
      for (final slot in availableTimeSlots) {
        times.add(slot['time_slot']);
      }
    });
  }

  Future<void> _showConfirmationDialog() async {
    if (isBooking) return; // Prevent showing dialog if booking is already in progress
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Appointment'),
          content: Text(
            'Are you sure you want to book an appointment for ${days[selectedDayIndex]} at ${times[selectedTimeIndex]}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isBooking ? null : () { // Disable button while booking
                Navigator.pop(context);
                _bookAppointment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: isBooking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment() async {
    setState(() => isBooking = true);

    final user = supabase.auth.currentUser;
    if (user == null) {
      CustomSnackBar.show(context: context, message: 'User not logged in');
      setState(() => isBooking = false);
      return;
    }

    final doctorId = 'b55f005f-3185-4fa3-9098-2179e0751621';
    // widget.doctor?['id'];
    if (doctorId == null) {
      CustomSnackBar.show(context: context, message: 'Doctor information not found');
      setState(() => isBooking = false);
      return;
    }

    if (selectedDayIndex < 0 || selectedDayIndex >= dates.length ||
        selectedTimeIndex < 0 || selectedTimeIndex >= times.length) {
      CustomSnackBar.show(context: context, message: 'Invalid date or time selection');
      setState(() => isBooking = false,);
      return;
    }

    try {
      // 🔍 Step 1: Get the patient_id that corresponds to the logged-in user
      final patient = await supabase
          .from('patients')
          .select('patient_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (patient == null) {
        CustomSnackBar.show(context: context, message: 'Patient profile not found');
        setState(() => isBooking = false);
        return;
      }

      final patientId = patient['patient_id'];
      final selectedDate = DateTime.parse(dates[selectedDayIndex]);

      // Check if the time slot is available
      final timeSlot = await supabase
          .from('time_slots_duplicate')
          .select()
          .eq('doctor_id', doctorId)
          .eq('available_date', selectedDate.toIso8601String().split('T')[0])
          .eq('status', 'available')
          .eq('time_slot', times[selectedTimeIndex])
          .maybeSingle();

      if (timeSlot == null) {
        CustomSnackBar.show(context: context, message: 'Selected time slot is not available');
        setState(() => isBooking = false);
        return;
      }

      // Start a transaction (using try-catch for error handling
      try {
        final newAppointment = {
          'appointment_id': const Uuid().v4(),
          'doctor_id': doctorId,
          'patient_id': patientId,
          'date': selectedDate.toIso8601String(),
          'time': times[selectedTimeIndex],
          'status': 'pending',
          'patient_confirmed': true,
          'doctor_confirmed': false,
          'notes': userNote,
          'type': appointmentType,
          'time_slot_id': timeSlot['slot_id'],
        };
        await supabase.from('appointments').insert(newAppointment);

        // Update the time slot status
        await supabase
            .from('time_slots_duplicate')
            .update({'status': 'booked'})
            .eq('slot_id', timeSlot['slot_id']);

        if (!mounted) return;
        CustomSnackBar.show(
          context: context,
          message: 'Appointment booked successfully!',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(
              goToAppointment: true,
              initialAppointments: [newAppointment],
            ),
          ),
        );

        // Notification insert is skipped to avoid database errors
        // final userId = Supabase.instance.client.auth.currentUser?.id;
        // if (userId != null) {
        //   await Supabase.instance.client.from('notifications').insert({
        //     'user_id': userId,
        //     'message': 'Your appointment has been confirmed.',
        //     'type': 'appointment',
        //     'status': 'unread',
        //     'created_at': DateTime.now().toIso8601String(),
        //     // Add other fields as needed
        //   });
        // }
      } catch (e) {
         if (!mounted) return;
         CustomSnackBar.show(
            context: context,
            message: 'Error booking appointment: ${e.toString()}',
          );
          print('Error booking appointment during insert/update: $e');
      }

    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Error during appointment process: ${e.toString()}',
      );
       print('Error during appointment process: $e');
    } finally {
      if (mounted) {
        setState(() => isBooking = false);
      }
    }
  }

  void _incrementNoteCount(String note) {
    setState(() {
      userNote = note;
      notesCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Book Appointment',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 240,
            child: Image.asset(
              widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
              fit: BoxFit.cover,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    _buildDoctorInfo(theme),
                    const SizedBox(height: 24),
                    _buildAppointmentTypeSelector(theme),
                    const SizedBox(height: 24),
                    _buildDateSelector(theme),
                    const SizedBox(height: 24),
                    _buildTimeSelector(theme),
                    const SizedBox(height: 32),
                    _buildBottomActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.doctor?['name'] ?? "Dr. Ahmed",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.doctor?['type'] ?? "Senior Neurologist and Surgeon",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
          Text(
            widget.doctor?['hospital'] ?? "Mirpur Medical College and Hospital",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTypeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointment Type", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    appointmentType = 'consultation';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: appointmentType == 'consultation' 
                        ? AppTheme.primaryColor 
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: appointmentType == 'consultation'
                          ? AppTheme.primaryColor
                          : theme.dividerColor,
                    ),
                  ),
                  child: Text(
                    'Consultation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appointmentType == 'consultation'
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    appointmentType = 'follow_up';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: appointmentType == 'follow_up'
                        ? AppTheme.primaryColor
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: appointmentType == 'follow_up'
                          ? AppTheme.primaryColor
                          : theme.dividerColor,
                    ),
                  ),
                  child: Text(
                    'Follow Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appointmentType == 'follow_up'
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointment", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90, // Set a fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length, // Use the dynamically generated dates list
            itemBuilder: (context, index) {
              final isSelected = index == selectedDayIndex;
              final date = DateTime.parse(dates[index]); // Parse the date string
              final dayOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7]; // Get day of the week

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDayIndex = index;
                    selectedTimeIndex = 0;
                  });
                  fetchAvailableTimeSlots();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12), // Add spacing between items
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7DDCFF) : Colors.transparent, // Use transparent for unselected
                    borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: isSelected ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.15)), // Add border for unselected
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek, // Display day of the week
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6), // Add spacing between day and date
                      Text(
                        "${date.day}/${date.month}", // Display date in Day/Month format
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
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
      ],
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Times", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(times.length, (index) {
            final isSelected = index == selectedTimeIndex;
            return GestureDetector(
              onTap: () {
                    setState(() {
                      selectedTimeIndex = index;
                    });
                    fetchAvailableTimeSlots();
                  },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.bookingTimeColor : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  times[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isBooking ? null : _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: isBooking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 12),
        Ink(
          decoration: const ShapeDecoration(
            color: AppTheme.bookingDayColor,
            shape: CircleBorder(),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.chat, color: AppTheme.primaryColor),
                onPressed: () async {
                  final selectedDate = '${dates[selectedDayIndex]} ${days[selectedDayIndex]}';
                  final selectedTime = times[selectedTimeIndex];
                  final note = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientNotesScreen(
                        date: selectedDate,
                        time: selectedTime,
                        imageUrl: widget.doctor?['image'] ?? 'assets/images/doctor_photo.png',
                        onNoteAdded: _incrementNoteCount,
                      ),
                    ),
                  );
                  if (note != null) {
                    _incrementNoteCount(note);
                  }
                },
              ),
              if (notesCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text('$notesCount', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
