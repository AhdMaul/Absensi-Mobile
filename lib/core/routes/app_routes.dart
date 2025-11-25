import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/screens/login_screens.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/absensi/screens/absensi_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/screens/history_screen.dart';
// Import other screens here

class AppRoutes {
  static const String login = '/login';
  static const String absensi = '/absensi';
  static const String home = '/home';
  static const String recognize = '/recognize';
  static const String history = '/history';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      absensi: (context) => const AbsensiScreen(),
      home: (context) => const HomeScreen(),
      history: (context) => const HistoryScreen(),
      //recognize: (context) =>
    };
  }

  // GetX named routes with bindings (recommended for GetX navigation)
  static List<GetPage> getPages() {
    return [
      GetPage(
        name: login,
        page: () => const LoginScreen(),
        binding: AuthBinding(),
      ),
      GetPage(
        name: home,
        page: () => const HomeScreen(),
        binding: HomeBinding(),
      ),
      GetPage(
        name: absensi,
        page: () => const AbsensiScreen(),
      ),
      GetPage(
        name: history,
        page: () => const HistoryScreen(),
      ),
    ];
  }

  // Optional: Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    // Use pushReplacementNamed safely with ModalRoute
    if (ModalRoute.of(context)?.settings.name != login) {
      Navigator.pushReplacementNamed(context, login);
    }
  }

  static void navigateToHome(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != home) {
      Navigator.pushReplacementNamed(context, home);
    }
  }

  static void navigateToAbsensi(BuildContext context) {
    if (ModalRoute.of(context)?.settings.name != absensi) {
      Navigator.pushNamed(context, absensi);
    }
  }
}