// lib/core/utils/app_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

class AppSnackbar {
  static void show(String title, String message, {String type = 'info'}) {
    Color accentColor;
    IconData iconData;

    switch (type) {
      case 'error':
        accentColor = AppColors.error;
        iconData = Icons.error_rounded;
        break;
      case 'success':
        accentColor = AppColors.neonGreen; 
        iconData = Icons.check_circle_rounded;
        break;
      case 'warning':
        accentColor = const Color(0xFFF59E0B); // Amber
        iconData = Icons.warning_rounded;
        break;
      default:
        // info
        accentColor = AppColors.neonCyan;
        iconData = Icons.info_rounded;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP, // Tampil di atas agar eye-catching
      snackStyle: SnackStyle.FLOATING,
      
      // --- PERUBAHAN TAMPILAN (SOLID & JELAS) ---
      backgroundColor: Colors.white, // Background Putih Solid (JELAS)
      colorText: AppColors.textPrimary, // Teks Hitam (KONTRAS)
      
      // Border agar terpisah dari background aplikasi
      borderColor: accentColor.withOpacity(0.5),
      borderWidth: 1.5,
      
      // Shadow agar terlihat "melayang"
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(
        iconData,
        color: accentColor, // Icon berwarna sesuai tipe
        size: 28,
      ),
      shouldIconPulse: false, 
      duration: const Duration(seconds: 3),
    );
  }
}