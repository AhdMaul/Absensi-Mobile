// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pastikan path ini benar
import 'core/routes/app_routes.dart'; 
import 'core/theme/app_theme.dart';
import 'app/bindings/app_binding.dart';
import 'core/widgets/connectivity_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all locale data for date formatting
  try {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('en_US', null);
  } catch (e) {
    print('Error initializing date formatting: $e');
  }
  
  // 1. Inisialisasi dependency via GetX bindings (AppBinding)
  // AppBinding akan mendaftarkan service & controller yang diperlukan
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      title: 'ESHRM Absensi', 
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 

      // Menggunakan GetX route system dengan bindings
      initialRoute: AppRoutes.login, 
      getPages: AppRoutes.getPages(),

      // Initial binding: jalankan dependency wiring sebelum aplikasi dimulai
      initialBinding: AppBinding(),

      // Builder untuk banner konektivitas (ConnectivityBanner kini pakai GetX)
      builder: (context, child) {
        return ConnectivityBanner(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}