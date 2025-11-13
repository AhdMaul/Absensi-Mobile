// lib/features/auth/widgets/login_header.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; // Sesuaikan path jika perlu

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GANTI DENGAN LOGO JIKA ADA
        // Contoh jika pakai logo:
        // SvgPicture.asset('assets/logo/jcode_logo.svg', height: 50),
        
        // Contoh jika pakai Icon:
        const Icon(
          Icons.fingerprint, // Icon absensi
          size: 50,
          color: kPrimaryRed,
        ),
        const SizedBox(height: 20),
        Text(
          'Selamat Datang di',
          // Font Satoshi akan otomatis diterapkan dari theme
          style: textTheme.headlineSmall?.copyWith(
            color: kTextColor.withOpacity(0.8),
          ),
        ),
        Text(
          'ESHRM Absensi',
          style: textTheme.headlineMedium?.copyWith(
            color: kDarkRed, // Warna merah tua
            fontWeight: FontWeight.w700, // Font Satoshi Bold (jika ada)
          ),
        ),
        Text(
          'by JCode Team',
          style: textTheme.bodyMedium?.copyWith(
            color: kTextColor.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}