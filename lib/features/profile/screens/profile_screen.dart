import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/profile_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Base color
      body: Stack(
        children: [
          // --- LAYER 1: Background Aurora Halus ---
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Stack(
                children: [
                  // Blob Cyan (Kanan Atas)
                  Positioned(
                    top: -50,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Gunakan withValues jika Flutter terbaru, atau withOpacity
                        color: AppColors.neonCyan.withOpacity(0.15), 
                      ),
                    ),
                  ),
                  // Blob Hijau (Kiri Tengah)
                  Positioned(
                    top: 200,
                    left: -80,
                    child: Container(
                      width: 250,
                      height: 250,
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

          // --- LAYER 2: Konten ---
          SafeArea(
            child: Column(
              children: [
                // AppBar Custom (Sederhana & Bersih)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Back
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        ),
                      ),
                      // Judul
                      Text(
                        'Profil Saya',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Placeholder untuk simetri (atau tombol setting)
                      const SizedBox(width: 40), 
                    ],
                  ),
                ),

                // Body
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 10, bottom: 30),
                    child: ProfileWidget(),
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