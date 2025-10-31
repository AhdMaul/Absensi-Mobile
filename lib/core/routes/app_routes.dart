import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../features/auth/screens/login_screens.dart';
import '../../features/absensi/screens/absensi_screen.dart';
import '../../features/home/screens/home_screen.dart';
// Import other screens here

class AppRoutes {
  static const String login = '/login';
  static const String absensi = '/absensi';
  static const String home = '/home';
  static const String recognize = '/recognize'; // Add other route names here

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
     absensi: (context) => const AbsensiScreen(),
    home: (context) => const HomeScreen(),
    //recognize: (context) =>
    };
  }

  // Optional: Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToRecognize(BuildContext context) {
    Navigator.pushReplacementNamed(context, absensi);
  }
}