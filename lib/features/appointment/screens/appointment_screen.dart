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
  int selectedDayIndex = 2;
  int selectedTimeIndex = 0;
  bool isBooking = false;
  int notesCount = 0;
  String userNote = "";

  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  final List<String> dates = ['3', '4', '5', '6', '7'];
  final List<String> times = ['09:00:00', '09:30:00', '10:00:00', '10:30:00'];

  final supabase = Supabase.instance.client;

  Future<void> _showConfirmationDialog() async {
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
              onPressed: () {
                Navigator.pop(context);
                _bookAppointment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Confirm'),
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
final doctorID = patient['doctor_id'];

final newAppointment = {
  'appointment_id': const Uuid().v4(),
  // 'doctor_id': widget.doctor?['id'],
  'doctor_id': "8542e414-78e2-40c7-9b9c-36748ac82c99",
  'patient_id': patientId, // ✅ must match auth.uid()
  'date': DateTime(
      DateTime.now().year,
      DateTime.now().month,
      int.parse(dates[selectedDayIndex]),
    ).toIso8601String(),
  'time': times[selectedTimeIndex],
  'status': 'pending',
  'patient_confirmed': true,
  'doctor_confirmed': false,
  'notes': userNote,
};

// await supabase.from('appointments').insert(newAppointment);

  // 📥 Step 3: Insert into the database
  final response = await supabase.from('appointments').insert(newAppointment);

  setState(() => isBooking = false);
  Navigator.pop(context);

// if (response == null) {
//   CustomSnackBar.show(context: context, message: 'Insert failed, no response.');
//   setState(() => isBooking = false);
//   return;
// }

  if (response.error == null && mounted) {
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
  } else {
    CustomSnackBar.show(
      context: context,
      message: 'Error: ${response.error?.message}',
    );
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

  Widget _buildDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Appointment", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: List.generate(days.length, (index) {
              final isSelected = index == selectedDayIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF7DDCFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          days[index],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dates[index],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
              onTap: () => setState(() => selectedTimeIndex = index),
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
