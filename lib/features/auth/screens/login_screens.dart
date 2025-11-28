import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_snackbar.dart';
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

  // --- Fungsi Custom untuk Animasi Spring/Bouncy ---
  void showSpringBottomSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan tap background
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5), // Background gelap
      transitionDuration: const Duration(milliseconds: 600), // Durasi animasi
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.bottomCenter,
          child: LoginBottomSheet(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Kurva ElasticOut memberikan efek "memantul" (Bouncy)
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut, 
          reverseCurve: Curves.easeOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Mulai dari bawah layar
            end: Offset.zero,          // Berhenti di posisi asli
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- LAYER 1: Aurora Gradient Background ---
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
                        color: AppColors.neonGreen.withAlpha((0.3 * 255).round()),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100, right: -50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neonCyan.withAlpha((0.3 * 255).round()),
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
                  const LoginHeader(),
                  const Spacer(),

                  // --- NEW PREMIUM ACTION BUTTONS ---
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        PremiumDarkButton(
                          text: 'Get Started',
                          icon: const Icon(
                            Icons.arrow_forward_rounded, 
                            color: Colors.white, 
                            size: 18
                          ),
                          onPressed: () {
                            // Panggil fungsi animasi baru di sini
                            showSpringBottomSheet(context);
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