import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/doctor_appointments_screen.dart';
import 'screens/doctor_reviews_screen.dart';
import 'screens/doctor_book_appointment_screen.dart';
import 'widgets/doctor_bottom_bar.dart';

class DoctorMainNavigation extends StatefulWidget {
  final bool goToAppointment;
  final List<Map<String, dynamic>>? initialAppointments;

  const DoctorMainNavigation({
    super.key,
    this.goToAppointment = false,
    this.initialAppointments,
  });

  @override
  State<DoctorMainNavigation> createState() => DoctorMainNavigationState();
}

class DoctorMainNavigationState extends State<DoctorMainNavigation> {
  int _currentIndex = 0;
  late List<Map<String, dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    if (widget.goToAppointment) {
      _currentIndex = 2;
    }
    _appointments = widget.initialAppointments ?? [];
  }

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void addAppointment(Map<String, dynamic> appointment) {
    setState(() {
      _appointments.add(appointment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _buildCurrentScreen(),
      bottomNavigationBar: DoctorBottomBar(
        currentIndex: _currentIndex,
        onTap: setTab,
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return DoctorHomeScreen(
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case 1:
        return const _DoctorUploadPlaceholder();
      case 2:
        return const DoctorBookAppointmentScreen();
      case 3:
        return const _ComingSoonPlaceholder(title: 'Patient');
      default:
        return DoctorHomeScreen(
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
    }
  }
}

class _DoctorUploadPlaceholder extends StatelessWidget {
  const _DoctorUploadPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Upload', style: AppTheme.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text('Upload Screen (Coming Soon)', 
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)
        ),
      ),
    );
  }
}

class _DoctorProfilePlaceholder extends StatelessWidget {
  const _DoctorProfilePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: AppTheme.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text('Profile Screen (Coming Soon)', 
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)
        ),
      ),
    );
  }
}

class _ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  const _ComingSoonPlaceholder({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title (Coming Soon)', style: AppTheme.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text('$title feature coming soon!',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor),
        ),
      ),
    );
  }
} 