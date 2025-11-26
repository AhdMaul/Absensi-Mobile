import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}