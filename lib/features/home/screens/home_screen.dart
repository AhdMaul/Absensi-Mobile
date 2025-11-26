import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports
import '../controllers/home_controller.dart';
import '../widgets/home_content.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/connectivity_banner.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    // Show welcome snackbar if coming from login
    Future.delayed(Duration.zero, () {
      final args = Get.arguments;
      if (args != null && args['showWelcome'] == true) {
        homeController.showWelcomeSnackbar();
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white, // Base color tetap putih
        body: Stack(
          children: [
            // --- LAYER 1: Background Aurora (DIKEMBALIKAN & DISESUAIKAN) ---
            Positioned.fill(
              child: ImageFiltered(
                // Blur tetap tinggi agar halus seperti asap/cahaya
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Stack(
                  children: [
                    // 1. Bola Hijau (Header Glow)
                    // Diposisikan di pojok kiri atas untuk highlight area "Selamat Datang"
                    Positioned(
                      top: -100, 
                      left: -80,
                      child: Container(
                        width: 350, 
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Opacity 0.15: Cukup terlihat segar, tapi tidak bikin tulisan hitam susah dibaca
                          color: AppColors.neonGreen.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    
                    // 2. Bola Cyan/Biru (Bottom Glow)
                    // Diposisikan di kanan bawah atau tengah untuk variasi
                    Positioned(
                      top: 200, 
                      right: -150,
                      child: Container(
                        width: 400, 
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Opacity 0.1: Lebih tipis biar tidak tabrakan sama kartu konten
                          color: AppColors.neonCyan.withValues(alpha: 0.1),
                        ),
                      ),
                    ),

                    // 3. (Opsional) Aksen kecil Ungu di tengah bawah untuk blend tombol "Masuk Lagi"
                    Positioned(
                      bottom: -100,
                      left: 50,
                      child: Container(
                        width: 300, 
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- LAYER 2: UI Content ---
            SafeArea(
              bottom: false, 
              child: Column(
                children: [
                  // AppBar Custom
                  Container(
                    margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          'Beranda',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w800, 
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Tombol Profil
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const ProfileScreen());
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.8), // Sedikit transparan biar background tembus dikit
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded, 
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Body
                  Expanded(
                    child: ConnectivityBanner(
                      child: const HomeContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}