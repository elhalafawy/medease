import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/upload/screens/upload_screen.dart';
import '../../features/appointment/screens/appointment_schedule_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../widgets/custom_bottom_bar.dart';

class MainNavigation extends StatefulWidget {
  final bool goToAppointment;

  const MainNavigation({super.key, this.goToAppointment = false});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.goToAppointment) {
      _currentIndex = 2; 
    }
  }

  void setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
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
          appointments: const [], // Added required parameter
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
