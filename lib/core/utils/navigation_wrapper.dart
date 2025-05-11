import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/upload/screens/upload_screen.dart';
import '../../features/appointment/screens/appointment_schedule_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../widgets/custom_bottom_bar.dart';
import '../theme/app_theme.dart' hide CustomBottomBar; // Modified import

class MainNavigation extends StatefulWidget {
  final bool goToAppointment;
  final List<Map<String, dynamic>>? initialAppointments;

  const MainNavigation({
    super.key,
    this.goToAppointment = false,
    this.initialAppointments,
  });

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
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
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTabChange: setTab,
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      case 1:
        return const UploadScreen();
      case 2:
        return AppointmentScheduleScreen(
          appointments: _appointments,
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
