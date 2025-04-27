import 'package:flutter/material.dart';
import '../Home/home_screen.dart';
import '../Upload/upload_screen.dart';
import '../Appointment/appointment_screen.dart';
import '../Profile/profile_screen.dart';
import '../../widgets/custom_bottom_bar.dart';

class MainNavigation extends StatefulWidget {
  final bool goToAppointment;

  const MainNavigation({super.key, this.goToAppointment = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.goToAppointment) {
      _currentIndex = 2; 
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
        return const AppointmentScreen(); 
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
