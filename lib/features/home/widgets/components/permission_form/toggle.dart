import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';

class PermissionToggle extends StatelessWidget {
  final bool isSick;
  final ValueChanged<bool> onChanged;

  const PermissionToggle({super.key, required this.isSick, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              "Izin / Cuti",
              !isSick,
              () => onChanged(false),
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              "Sakit",
              isSick,
              () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isActive ? (isSick ? AppColors.error : const Color(0xFF3B82F6)) : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
