// lib/features/profile/widgets/profile_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/services/auth_service.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  String _userName = "Memuat...";
  String _userEmail = "Memuat...";
  String _userRole = "Karyawan";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('userName') ?? "Deswita"; 
        _userEmail = "deswita@eshrm.com";
      });
    }
  }

  // --- FUNGSI LOGOUT DENGAN KONFIRMASI ---
  Future<void> _handleLogout() async {
    // Tampilkan Dialog Konfirmasi terlebih dahulu
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Menghilangkan tint Material 3
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          // Tombol Keluar (Merah)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Keluar',
              style: GoogleFonts.hankenGrotesk(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    // Jika user memilih "Keluar" (true), baru jalankan proses logout
    if (shouldLogout == true) {
      await AuthService().logout();
      if (mounted) {
         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // --- 1. FOTO PROFIL BESAR ---
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      // FIX: Gunakan withValues
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : "?",
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // Tombol Edit Foto
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.buttonBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nama & Role
          Text(
            _userName,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              // FIX: Gunakan withValues
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userRole,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                // FIX: Gunakan withValues
                color: AppColors.neonCyan.withValues(alpha: 1.0)
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- 2. STATISTIK RINGKAS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("Hadir", "22", Colors.green),
              _buildVerticalDivider(),
              _buildStatItem("Telat", "1", Colors.orange),
              _buildVerticalDivider(),
              _buildStatItem("Izin", "0", Colors.blue),
            ],
          ),

          const SizedBox(height: 30),

          // --- 3. MENU SETTINGS (AKUN) ---
          _buildSectionTitle("Akun"),
          const SizedBox(height: 10),
          Container(
            // PERBAIKAN: clipBehavior agar shadow klik tidak kotak
            clipBehavior: Clip.hardEdge, 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // FIX: Gunakan withValues
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _buildMenuTile(Icons.person_outline_rounded, "Edit Data Diri", onTap: () {}),
                _buildDivider(),
                _buildMenuTile(Icons.lock_outline_rounded, "Ganti Password", onTap: () {}),
                _buildDivider(),
                _buildMenuTile(Icons.notifications_none_rounded, "Notifikasi", onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 4. MENU LAINNYA ---
          _buildSectionTitle("Lainnya"),
          const SizedBox(height: 10),
          Container(
            // PERBAIKAN: clipBehavior agar shadow klik tidak kotak
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // FIX: Gunakan withValues
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _buildMenuTile(Icons.help_outline_rounded, "Bantuan & Support", onTap: () {}),
                _buildDivider(),
                _buildMenuTile(
                  Icons.logout_rounded, 
                  "Keluar Akun", 
                  isDestructive: true,
                  onTap: _handleLogout // Panggil fungsi logout yang baru
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {required VoidCallback onTap, bool isDestructive = false}) {
    return Material(
      color: Colors.transparent, // Agar warna background dari Container terlihat
      child: InkWell(
        onTap: onTap,
        // Warna splash lebih halus (FIX: Gunakan withValues)
        splashColor: isDestructive ? AppColors.error.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        highlightColor: isDestructive ? AppColors.error.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // FIX: Gunakan withValues
                  color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? AppColors.error : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded, 
                size: 20, 
                color: Colors.grey.shade400
              ),
            ],
          ),
        ),
      ),
    );
  }
}