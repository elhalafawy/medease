import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Camera/Camera.dart';
import 'screens/Before home/splash_screen.dart';
import 'screens/Before home/welcome_screen.dart';
import 'screens/Before home/login_screen.dart';
import 'screens/Before home/register_screen.dart';
import 'screens/Before home/forgot_password_screen.dart';
import 'screens/Themes/navigation_wrapper.dart'; 
import 'screens/Before home/change_password_screen.dart';
import 'screens/Profile/notifications_screen.dart';
import 'screens/Profile/profile_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MedEaseApp());
  // runApp(const CameraScreen());
}

class MedEaseApp extends StatelessWidget {
  const MedEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MedEase',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
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
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) =>  RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigation(), 
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
  path: '/change-password',
  builder: (context, state) => const ChangePasswordScreen(),
  ),
  GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationsScreen(),
),
   GoRoute(
  path: '/profile',
  builder: (context, state) => const ProfileScreen(),
),

  ],
);
