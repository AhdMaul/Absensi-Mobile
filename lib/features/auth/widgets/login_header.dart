import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Rata Kiri
      children: [
        // 1. BRAND IDENTITY (Nama Aplikasi)
        // Dibuat lebih kecil dan tidak terlalu bold, seperti logo di surat resmi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'ATTENDIFY APP',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700, // Tidak w900, cukup w700
             color: const Color(0xFF4F46E5), 
              letterSpacing: 2.0, // Spasi antar huruf agar elegan
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // 2. BIG HEADLINE (Judul Utama yang Menarik)
        // Ini mengisi kekosongan "text dikit" di desain sebelumnya
        Text(
          'Simplify Your\nDaily Workflow.',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 36, // Ukuran besar
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1, // Jarak antar baris dirapatkan dikit
            letterSpacing: -1.0,
          ),
        ),

        const SizedBox(height: 12),

        // 3. SUBTITLE (Deskripsi Panjang)
        // Menjelaskan value aplikasi dengan kalimat lengkap
        Padding(
          padding: const EdgeInsets.only(right: 40.0), // Padding kanan agar teks tidak mentok layar
          child: Text(
            'Experience the most secure and efficient way to track attendance via GPS and Biometrics. Start your day with productivity.',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5, // Line height agar mudah dibaca
            ),
            textAlign: TextAlign.left,
          ),
        ),

        const SizedBox(height: 32),

        // 4. ILLUSTRATION
        // Gambar ditaruh di tengah container, tapi flow text tetap rata kiri
        Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 260),
            child: Image.asset(
              'assets/images/vector.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}