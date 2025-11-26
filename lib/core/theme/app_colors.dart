import 'package:flutter/material.dart';

class AppColors {
  // --- Warna Design Baru (Dark & Neon) ---
  static const Color bgBlack = Color(0xFF050505);
  static const Color neonGreen = Color(0xFF4ADE80);
  static const Color neonCyan = Color(0xFF2DD4BF);
  // Mengubah buttonBlack menjadi sedikit lebih terang untuk pangkal gradien
  static const Color buttonBlack = Color(0xFF1A1A1A); 

  // --- NEW: Warna Khusus untuk Tombol Premium ---
  static const Color buttonGradientTop = Color(0xFF1A1A1A); // Hitam pekat
  static const Color buttonGradientBottom = Color(0xFF333333); // Abu tua untuk bawah
  static const Color buttonInnerGlow = Color(0xFFFFFFFF); // Putih untuk pantulan bawah
  static const Color glassBorder = Color(0xFFE0E0E0); // Border halus untuk glass button

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF666666);

  // UI Elements
  static const Color inputFill = Color(0xFFF5F6F8);
  static const Color inputBorder = Color(0xFFE0E0E0);

  // Status
  static const Color error = Color(0xFFD32F2F);

  static const Color primaryButton = buttonBlack;
  static const Color primaryButtonGradient = buttonBlack;
}