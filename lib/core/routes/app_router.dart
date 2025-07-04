import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/doctor/screens/doctors_screen.dart';
import '../../features/doctor/screens/doctor_details_screen.dart';
import '../../features/appointment/screens/appointment_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../doctor_dashboard/doctor_router.dart';
import '../utils/navigation_wrapper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          initialEmail: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => DoctorsScreen(
          category: state.extra as String? ?? 'All',
        ),
      ),
      GoRoute(
        path: '/doctor-details',
        builder: (context, state) => DoctorDetailsScreen(
          doctor: state.extra as Map<String, dynamic>,
        ),
      ),
      GoRoute(
        path: '/appointment',
        builder: (context, state) => const AppointmentScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/doctor-dashboard',
        pageBuilder: (context, state) => const MaterialPage(
          child: Navigator(
            onGenerateRoute: DoctorRouter.generateRoute,
            initialRoute: DoctorRoutes.home,
          ),
        ),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigation(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
} 