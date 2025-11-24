import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/login_header.dart';
import '../widgets/login_bottom_sheet.dart';
import '../controllers/auth_controller.dart';

// Ubah menjadi StatefulWidget untuk menangani Animasi
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<Offset> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    // Setup Animasi: Durasi 1 detik (cukup lambat agar elegan)
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Ulangi bolak-balik (Maju-Mundur)

    // Definisi Gerakan: Geser dari posisi 0 ke kanan sedikit (0.25)
    _arrowAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.25, 0.0), // Geser horizontal sekitar 25% ukuran icon
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut, // Gerakan halus (lambat di awal/akhir, cepat di tengah)
    ));
  }

  @override
  void dispose() {
    _arrowController.dispose(); // Bersihkan controller saat layar ditutup
    super.dispose();
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
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Gunakan withValues atau withAlpha jika withOpacity deprecated di SDK barumu
                        color: AppColors.neonGreen.withOpacity(0.3),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
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

                  // Header (Logo & Vector)
                  const LoginHeader(),

                  const Spacer(),

                  // --- Action Button with Animation ---
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBlack,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 8,
                            shadowColor: AppColors.buttonBlack.withOpacity(0.4),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 12), // Jarak teks ke panah
                              
                              // --- ANIMATED ARROW ---
                              SlideTransition(
                                position: _arrowAnimation,
                                child: const Icon(
                                  Icons.arrow_forward_rounded, 
                                  size: 22
                                ),
                              ),
                            ],
                          ),
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