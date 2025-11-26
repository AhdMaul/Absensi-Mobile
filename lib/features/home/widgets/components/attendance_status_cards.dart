import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceStatusCards extends StatelessWidget {
  final String? checkInTime;
  final String? checkOutTime;

  const AttendanceStatusCards({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          title: "Absen Masuk",
          time: checkInTime ?? "--:--",
          icon: Icons.login_rounded,
          color: AppColors.neonGreen,
        ),
        const SizedBox(width: 16),
        _buildCard(
          title: "Absen Pulang",
          time: checkOutTime ?? "--:--",
          icon: Icons.logout_rounded,
          color: AppColors.neonCyan,
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required String time, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // UBAH: Warna putih SOLID (jangan pakai withValues/opacity)
          // Agar kontras dengan background layar yang abu-abu muda
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), // Radius diperhalus
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200, // Shadow warna abu soft
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}