// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Warna Design Baru (Dark & Neon) ---
  static const Color bgBlack = Color(0xFF050505);      // Background Utama
  static const Color neonGreen = Color(0xFF4ADE80);    // Aksen Hijau
  static const Color neonCyan = Color(0xFF2DD4BF);     // Aksen Biru
  static const Color buttonBlack = Color(0xFF121212);  // Warna Tombol Hitam
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Untuk di atas putih
  static const Color textWhite = Color(0xFFFFFFFF);   // Untuk di atas hitam
  static const Color textSecondary = Color(0xFF666666);

  // UI Elements
  static const Color inputFill = Color(0xFFF5F6F8);
  static const Color inputBorder = Color(0xFFE0E0E0);
  
  // Status
  static const Color error = Color(0xFFD32F2F);

  // --- COMPATIBILITY FIX (Agar error hilang) ---
  // Kita arahkan variabel lama 'primaryButton' ke 'buttonBlack'
  static const Color primaryButton = buttonBlack; 
  static const Color primaryButtonGradient = buttonBlack; // Tidak pakai gradasi lagi
}