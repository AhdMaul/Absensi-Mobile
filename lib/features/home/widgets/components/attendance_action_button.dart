// lib/features/home/presentation/components/attendance_action_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isCompleted; // Tetap disimpan untuk kompatibilitas, meski di controller kita set false

  const AttendanceActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isCompleted = false,
  });

  @override
  State<AttendanceActionButton> createState() => _AttendanceActionButtonState();
}

class _AttendanceActionButtonState extends State<AttendanceActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _btnController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animasi 'Breathing' agar tombol terasa hidup dan memanggil untuk ditekan
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika isCompleted true (opsional), warnanya abu. Jika tidak, pakai warna dinamis.
    final backgroundColor = widget.isCompleted ? Colors.grey.shade400 : widget.color;
    
    return ScaleTransition(
      scale: widget.isCompleted ? const AlwaysStoppedAnimation(1.0) : _scaleAnimation,
      child: Container(
        height: 70, // Sedikit lebih tinggi agar gagah
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Efek Glow / Shadow menyesuaikan warna tombol
          boxShadow: [
            if (!widget.isCompleted)
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 1,
              ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0, // Elevation kita handle manual di Container shadow biar lebih smooth
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          onPressed: widget.isCompleted ? null : widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Icon kiri, text tengah, panah kanan
            children: [
              // 1. Icon Utama
              Icon(widget.icon, size: 28),
              
              // 2. Teks Tombol
              Text(
                widget.text,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18, 
                  fontWeight: FontWeight.w700, 
                  letterSpacing: 0.5
                ),
              ),

              // 3. Indikator Panah (Agar user tau ini bisa di-klik)
              if (!widget.isCompleted)
                const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white70)
              else
                const SizedBox(width: 18), // Placeholder biar text tetap di tengah
            ],
          ),
        ),
      ),
    );
  }
}