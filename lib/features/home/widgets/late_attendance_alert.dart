// lib/features/home/widgets/late_attendance_alert.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget ini terinspirasi dari referensi
class LateAttendanceAlert extends StatelessWidget {
  final String message;
  const LateAttendanceAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Gradient merah/orange yang soft
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade100.withOpacity(0.6),
            Colors.red.shade100.withOpacity(0.6),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.hankenGrotesk(
                color: Colors.red.shade900,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}