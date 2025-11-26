import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

// --- 1. Tombol Gelap Premium (Tidak ada perubahan) ---
class PremiumDarkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? icon;

  const PremiumDarkButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.buttonGradientTop,
              AppColors.buttonGradientBottom,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 2,
              right: 2,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.buttonInnerGlow.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 30),
                          Text(
                            text,
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (icon != null)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              child: Center(child: icon),
                            )
                          else
                            const SizedBox(width: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Tombol Kaca / Glassmorphism (DIPERBARUI AGAR LEBIH JELAS) ---
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GlassButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Bayangan sedikit diperkuat agar tombol lebih "angkat"
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Opacity naik dikit
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            // Blur diperkuat agar efek kaca lebih terasa
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                // UBAH: Menggunakan Gradient agar lebih berdimensi dan terlihat
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(
                      0.7,
                    ), // Lebih pekat di kiri atas (sumber cahaya)
                    Colors.white.withOpacity(
                      0.4,
                    ), // Lebih transparan di kanan bawah
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                // UBAH: Border lebih tegas (hampir solid putih)
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    // Warna teks tetap gelap agar kontras
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
