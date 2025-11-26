import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class RealtimeClockCard extends StatelessWidget {
  final DateTime currentTime;

  const RealtimeClockCard({super.key, required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.buttonBlack.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM').format(currentTime),
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('HH:mm:ss').format(currentTime),
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Icon(Icons.access_time_filled_rounded, color: AppColors.neonGreen, size: 36),
        ],
      ),
    );
  }
}