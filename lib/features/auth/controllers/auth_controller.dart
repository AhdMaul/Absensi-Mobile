import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../../../core/routes/app_routes.dart'; 
import '../../../core/theme/app_colors.dart'; 

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // --- 1. Validasi Input Kosong ---
    if (email.isEmpty) {
      _showSoftSnackbar(
        title: "Email Belum Diisi",
        message: "Mohon isi alamat email kamu dulu ya.",
        type: 'warning',
      );
      return;
    }

    if (password.isEmpty) {
      _showSoftSnackbar(
        title: "Password Kosong",
        message: "Jangan lupa masukkan kata sandi kamu ya.",
        type: 'warning',
      );
      return;
    }

    // --- 2. Proses Login ---
    isLoading.value = true;

    try {
      final response = await _authService.login(email, password);

      // --- 3. Cek Hasil Login ---
      if (response.success) {
        // SUKSES
        Get.offAllNamed(AppRoutes.home, arguments: {'showWelcome': true});
      } else {
        // GAGAL (Bisa karena salah password ATAU backend mati)
        // Kita cek isi pesan error dari response untuk membedakan
        
        String errorMsg = response.message.toLowerCase();

        // Cek kata kunci error dari backend (sesuaikan dengan return API backendmu)
        // Biasanya: "Email atau password salah", "User not found", "401", dll.
        bool isCredentialError = errorMsg.contains('salah') || 
                                 errorMsg.contains('email') || 
                                 errorMsg.contains('password') ||
                                 errorMsg.contains('user') ||
                                 errorMsg.contains('credential');

        if (isCredentialError) {
          // KASUS 1: Salah Password / Email
          _showSoftSnackbar(
            title: "Gagal Masuk",
            message: "Hmm, sepertinya email atau kata sandi kurang tepat. Coba dicek lagi ya.",
            type: 'error',
          );
        } else {
          // KASUS 2: Error Lain (Backend Mati / Koneksi)
          // response.message berisi "Connection refused" dll.
          _showSoftSnackbar(
            title: "Ada Kendala",
            message: "Maaf, sepertinya server sedang istirahat atau koneksi bermasalah. Coba lagi nanti ya.",
            type: 'error',
          );
        }
      }
    } catch (e) {
      // Error Sistem/Jaringan yang tidak tertangkap di Service
      _showSoftSnackbar(
        title: "Ada Kendala",
        message: "Maaf, sistem sedang sibuk atau koneksi terputus. Coba sesaat lagi ya.",
        type: 'error',
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // --- Helper Widget: Snackbar Ramah ---
  void _showSoftSnackbar({required String title, required String message, required String type}) {
    Color bgColor;
    Color textColor;
    IconData icon;

    if (type == 'error') {
      bgColor = const Color(0xFFEF4444); // Warna Merah
      textColor = const Color(0xFF7F1D1D); 
      icon = Icons.sentiment_dissatisfied_rounded;
    } else { // warning
      bgColor = const Color(0xFFF59E0B); // Warna Amber
      textColor = const Color(0xFF78350F); 
      icon = Icons.info_outline_rounded;
    }

    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textColor.withValues(alpha: 0.8),
        ),
      ),
      snackPosition: SnackPosition.TOP,
      // Ubah ke transparent dengan alpha rendah
      backgroundColor: bgColor.withValues(alpha: 0.18),
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      icon: Icon(icon, color: bgColor.withValues(alpha: 0.9), size: 28),
      shouldIconPulse: true,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}