// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart'; 

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      primaryColor: kPrimaryRed,
      scaffoldBackgroundColor: kBackgroundColor,

      textTheme: GoogleFonts.getTextTheme('Outfit', baseTheme.textTheme).apply(
        bodyColor: kTextColor,
        displayColor: kTextColor,
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryRed,
        primary: kPrimaryRed,
        secondary: kDarkRed,
        surface: kBackgroundColor, 
        error: kErrorColor,
        brightness: Brightness.light,
      ),

      // Tema untuk Input Field (TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        // Font 'Satoshi' akan otomatis terpakai dari 'textTheme' di atas
        labelStyle: TextStyle(color: kDarkRed.withOpacity(0.8)), 
        floatingLabelStyle: const TextStyle( 
          color: kPrimaryRed,
          fontWeight: FontWeight.w600,
        ),
        
        // --- PERBAIKAN DEPREKASI 'MaterialState' ---
        prefixIconColor: WidgetStateColor.resolveWith((states) { 
          if (states.contains(WidgetState.focused)) { 
            return kPrimaryRed; 
          }
          if (states.contains(WidgetState.error)) { 
            return kErrorColor;
          }
          return kInputGray; 
        }),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: kInputGray.withOpacity(0.7), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kPrimaryRed, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kErrorColor, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: kErrorColor, width: 2.0),
        ),
      ),

      // Tema untuk seleksi teks
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: kPrimaryRed.withOpacity(0.25),
        selectionHandleColor: kPrimaryRed,
        cursorColor: kPrimaryRed,
      ),

      // Tema untuk AppBar
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: kDarkRed),
        titleTextStyle: baseTheme.textTheme.titleLarge?.copyWith(
          color: kDarkRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}