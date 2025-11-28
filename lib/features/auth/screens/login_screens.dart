import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
// Import widget tombol baru
import '../../../core/widgets/premium_buttons.dart'; 
import '../widgets/login_header.dart';
import '../widgets/login_bottom_sheet.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // --- Animasi Panah Lama Dihapus karena icon di referensi berbeda ---
  // Jika ingin tetap pakai panah animasi, bisa dimasukkan ke parameter icon di PremiumDarkButton

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- LAYER 1: Aurora Gradient Background (Tetap sama) ---
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Stack(
                children: [
                  Positioned(
                    top: -50, left: -50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Menggunakan withOpacity sesuai kode asli
                        color: AppColors.neonGreen.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100, right: -50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- LAYER 2: Content ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),

                  // Header (Logo & Vector) -
                  const LoginHeader(),

                  const Spacer(),

                  // --- NEW PREMIUM ACTION BUTTONS ---
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // 1. Tombol Utama (Dark Premium)
                        PremiumDarkButton(
                          text: 'Get Started',
                          icon: const Icon(
                            Icons.arrow_forward_rounded, 
                            color: Colors.white, 
                            size: 18
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const LoginBottomSheet(),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16), // Jarak antar tombol

                        // 2. Tombol Kedua (Glassmorphism) - Sesuai referensi
                        GlassButton(
                          text: 'Learn More', // Teks contoh untuk tombol kedua
                          onPressed: () {
                            // Aksi untuk tombol kedua (misal ke website)
                            AppSnackbar.show(
                              "Info",
                              "Fitur belum tersedia",
                              type: 'info',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}