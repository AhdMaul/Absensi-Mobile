// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart'; // <-- Pastikan import ini ada

class AppTheme {
  // Kita buat getter static agar mudah dipanggil
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Mengatur warna dasar aplikasi
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryButton, // Menggunakan Orange sebagai seed
        primary: AppColors.primaryButton,
        secondary: AppColors.textPrimary,
        error: AppColors.error,
        surface: Colors.white,
      ),
      
      scaffoldBackgroundColor: Colors.white, // Default putih, nanti ditimpa gradient

      // Mengatur Font Default ke Hanken Grotesk
      textTheme: GoogleFonts.hankenGroteskTextTheme(),
      
      // Style Input Field Global (Cadangan jika widget custom gagal)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryButton, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // Style Button Global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}