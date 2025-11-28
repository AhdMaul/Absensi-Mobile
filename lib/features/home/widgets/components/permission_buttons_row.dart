import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import 'permission_form_modal.dart'; // Kita buat file ini di langkah ke-2

class PermissionButtonsRow extends StatelessWidget {
  const PermissionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol Izin
        _buildOptionButton(
          context,
          label: "Izin / Cuti",
          icon: Icons.assignment_turned_in_rounded,
          color: const Color(0xFF3B82F6), // Soft Blue
          onTap: () => _showPermissionForm(context, isSick: false),
        ),
        const SizedBox(width: 16),
        // Tombol Sakit
        _buildOptionButton(
          context,
          label: "Sakit",
          icon: Icons.sick_rounded,
          color: const Color(0xFFEF4444), // Soft Red
          onTap: () => _showPermissionForm(context, isSick: true),
        ),
      ],
    );
  }

  void _showPermissionForm(BuildContext context, {required bool isSick}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PermissionFormModal(initialIsSick: isSick),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}