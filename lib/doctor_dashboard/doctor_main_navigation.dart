import 'package:flutter/material.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/doctor_appointments_screen.dart';
import 'screens/doctor_reviews_screen.dart';
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
        return DoctorAppointmentsScreen(
          appointments: _appointments,
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 3:
        return const _DoctorProfilePlaceholder();
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
      appBar: AppBar(
        title: const Text('Upload'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Upload Screen (قريبًا)', style: TextStyle(fontSize: 20, color: Colors.grey)),
      ),
    );
  }
}

class _DoctorProfilePlaceholder extends StatelessWidget {
  const _DoctorProfilePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Profile Screen (قريبًا)', style: TextStyle(fontSize: 20, color: Colors.grey)),
      ),
    );
  }
} 