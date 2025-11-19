// lib/features/auth/screens/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/login_header.dart';
import '../widgets/login_bottom_sheet.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white, // KEMBALI KE PUTIH
      body: Stack(
        children: [
          // --- LAYER 1: Gradient Aurora (Versi Light Mode) ---
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 90,
                sigmaY: 90,
              ), // Blur tetap tinggi
              child: Stack(
                children: [
                  // Blob 1: Hijau Pastel (Posisi Kiri Atas)
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Warna lebih soft (opacity dikurangi) untuk bg putih
                        color: AppColors.neonGreen.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Blob 2: Cyan/Biru Pastel (Posisi Kanan Tengah)
                  Positioned(
                    top: 200,
                    right: -60,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withOpacity(0.25),
                      ),
                    ),
                  ),
                  // Blob 3: Tambahan Blob Kecil di Bawah (Opsional, biar imbang)
                  Positioned(
                    bottom: -50,
                    left: 50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonGreen.withOpacity(0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- LAYER 2: Konten Utama ---
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                const LoginHeader(),

                const Spacer(flex: 3), // --- Tombol Get Started Hitam ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.buttonBlack, // Tetap Hitam
                            foregroundColor: Colors.white, // Teks Putih
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const LoginBottomSheet(),
                            );
                          },
                          child: Text(
                            'Login',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Link Text (Warna Gelap)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
