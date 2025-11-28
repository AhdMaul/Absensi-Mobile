// lib/features/home/widgets/components/attendance_action_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color; 
  final VoidCallback onPressed;
  final bool isCompleted; 

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
  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animasi Khusus Icon: Pulse (Detak Jantung)
    // Berjalan terus menerus (repeat)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Durasi satu siklus nafas
    )..repeat(reverse: true);

    // Ikon akan membesar dari 1.0 ke 1.2 lalu kembali lagi
    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  LinearGradient _getGradient(Color baseColor) {
    if (baseColor.value == const Color(0xFF4ADE80).value || baseColor == Colors.green) {
       return const LinearGradient(
        colors: [Color(0xFF059669), Color(0xFF34D399)], 
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (baseColor == Colors.orange.shade800 || baseColor == Colors.red || baseColor == Colors.orange) {
      return const LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFB923C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (baseColor == const Color(0xFF6C63FF) || baseColor == Colors.deepPurple) {
      return const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [baseColor, baseColor.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final useGradient = !widget.isCompleted;
    final gradient = useGradient ? _getGradient(widget.color) : null;
    final backgroundColor = widget.isCompleted ? Colors.grey.shade300 : null;
    final contentColor = widget.isCompleted ? Colors.grey.shade600 : Colors.white;

    return GestureDetector(
      onTap: widget.isCompleted ? null : widget.onPressed,
      child: Container(
        height: 80, // Tinggi diperbesar sedikit
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!widget.isCompleted)
              BoxShadow(
                color: widget.color.withOpacity(0.3), // Shadow lebih tegas
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            if (widget.isCompleted)
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Inner Highlight
            if (!widget.isCompleted)
              Positioned(
                top: 0, left: 0, right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // --- BAGIAN ICON (DIBERI ANIMASI) ---
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isCompleted 
                          ? Colors.white.withOpacity(0.5) 
                          : Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    // Gunakan ScaleTransition HANYA pada Icon ini
                    child: widget.isCompleted
                        ? Icon(widget.icon, color: contentColor, size: 24)
                        : ScaleTransition(
                            scale: _iconScaleAnimation,
                            child: Icon(
                              widget.icon, 
                              color: contentColor, 
                              size: 24
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: 20),

                  // Teks
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.text,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700, 
                            color: contentColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (!widget.isCompleted)
                          Text(
                            "Tap to confirm", 
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: contentColor.withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Panah (Juga diberi sedikit animasi gerak kiri-kanan agar dinamis)
                  if (!widget.isCompleted)
                   _AnimatedArrow(color: contentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Kecil untuk Animasi Panah (Maju Mundur)
class _AnimatedArrow extends StatefulWidget {
  final Color color;
  const _AnimatedArrow({required this.color});

  @override
  State<_AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<_AnimatedArrow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0.0), // Gerak ke kanan sedikit
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Icon(
        Icons.arrow_forward_rounded, 
        size: 22, 
        color: widget.color.withOpacity(0.8),
      ),
    );
  }
}