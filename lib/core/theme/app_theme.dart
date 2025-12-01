// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart'; 

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryButton,
        primary: AppColors.primaryButton, // Warna tombol OK/Cancel
        secondary: AppColors.textPrimary,
        error: AppColors.error,
        surface: Colors.white,
        onSurface: AppColors.textPrimary, // Warna teks tanggal
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.hankenGroteskTextTheme(),

      // --- TAMBAHAN: CUSTOM DATE PICKER THEME ---
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: AppColors.buttonBlack, // Header jadi Hitam
        headerForegroundColor: Colors.white, // Teks header Putih
        // Warna lingkaran tanggal yang dipilih
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neonCyan; 
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) {
            return Colors.white; 
          }
          return AppColors.textPrimary;
        }),
        todayBackgroundColor: WidgetStateProperty.all(AppColors.inputFill),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primaryButton),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      // -------------------------------------------

      // ... (sisa kode inputDecorationTheme dan elevatedButtonTheme biarkan sama)
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