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
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // --- LAYER 1: Background Aurora ---
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Stack(
                  children: [
                    Positioned(
                      top: -100, left: -100,
                      child: Container(
                        width: 300, height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonGreen.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150, right: -100,
                      child: Container(
                        width: 400, height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neonCyan.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- LAYER 2: UI Content ---
            SafeArea(
              bottom: false, // Biarkan konten bawah mengalir
              child: Column(
                children: [
                  // AppBar Custom
                  Container(
                    // Margin atas agar tidak mepet status bar
                    margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                    // Padding Horizontal 24.0 (Konsisten dengan HomeWidget)
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          'Beranda',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w800, // Extra Bold
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
                              color: Colors.white.withValues(alpha: 0.8),
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