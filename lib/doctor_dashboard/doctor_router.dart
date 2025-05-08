import 'package:flutter/material.dart';
import 'doctor_main_navigation.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/doctor_appointments_screen.dart';
import 'screens/doctor_reviews_screen.dart';

class DoctorRoutes {
  static const String home = '/doctor/home';
  static const String appointments = '/doctor/appointments';
  static const String reviews = '/doctor/reviews';
  static const String profile = '/doctor/profile';
  static const String upload = '/doctor/upload';
}

class DoctorRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case DoctorRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const DoctorMainNavigation(),
        );
      case DoctorRoutes.appointments:
        return MaterialPageRoute(
          builder: (_) => const DoctorMainNavigation(goToAppointment: true),
        );
      case DoctorRoutes.reviews:
        return MaterialPageRoute(
          builder: (_) => const DoctorReviewsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const DoctorMainNavigation(),
        );
    }
  }
} 