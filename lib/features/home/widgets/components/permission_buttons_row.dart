// lib/features/home/widgets/components/permission_buttons_row.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'permission_form_modal.dart'; // Import Modal Form

class PermissionButtonsRow extends StatelessWidget {
  const PermissionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol Izin / Cuti
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

  // Fungsi untuk menampilkan Modal
  void _showPermissionForm(BuildContext context, {required bool isSick}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // WAJIB: Agar modal bisa resize saat keyboard muncul
      backgroundColor: Colors.transparent, // Transparan agar rounded corner terlihat
      builder: (context) => PermissionFormModal(initialIsSick: isSick),
    );
  }

  // Widget Tombol Custom
  Widget _buildOptionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.15)),
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
      ),
    );
  }
}