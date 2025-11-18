// lib/features/auth/widgets/login_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Title
        Text(
          'ATTENDIFY',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, // KEMBALI KE HITAM/GELAP
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        
        // 2. Tagline
        Text(
          'Smart, Simple, Secure Attendance.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary, // ABU-ABU GELAP
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // 3. Vector Image
        Container(
          // Shadow dikurangi agar tidak terlalu kotor di background putih
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/vector.png', 
            height: 300,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}