// lib/features/home/widgets/late_attendance_alert.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LateAttendanceAlert extends StatelessWidget {
  final String message;
  const LateAttendanceAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // UBAH: Hapus LinearGradient, ganti dengan warna solid yang soft
        color: Colors.red.shade50, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          // Icon Sedikit lebih kecil agar proporsional
          Icon(
            Icons.info_outline_rounded, // Ganti icon biar lebih friendly (optional)
            color: Colors.red.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.hankenGrotesk(
                color: Colors.red.shade900,
                fontWeight: FontWeight.w600, // Sedikit lebih tebal agar terbaca di background terang
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}