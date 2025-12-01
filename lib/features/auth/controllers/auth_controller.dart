// lib/features/auth/controllers/auth_controller.dart
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
      _showSolidSnackbar(
        title: "Email Belum Diisi",
        message: "Mohon isi alamat email kamu dulu ya.",
        type: 'warning',
      );
      return;
    }

    if (password.isEmpty) {
      _showSolidSnackbar(
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
        // GAGAL
        String errorMsg = response.message.toLowerCase();
        bool isCredentialError = errorMsg.contains('salah') || 
                                 errorMsg.contains('email') || 
                                 errorMsg.contains('password') ||
                                 errorMsg.contains('user') ||
                                 errorMsg.contains('credential');

        if (isCredentialError) {
          _showSolidSnackbar(
            title: "Gagal Masuk",
            message: "Email atau kata sandi salah. Silakan cek kembali.",
            type: 'error',
          );
        } else {
          _showSolidSnackbar(
            title: "Ada Kendala",
            message: "Koneksi bermasalah atau server sibuk. Coba lagi nanti.",
            type: 'error',
          );
        }
      }
    } catch (e) {
      _showSolidSnackbar(
        title: "Ada Kendala",
        message: "Terjadi kesalahan sistem. Coba sesaat lagi.",
        type: 'error',
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // --- HELPER: SOLID SNACKBAR (Jelas & Terbaca) ---
  void _showSolidSnackbar({required String title, required String message, required String type}) {
    Color accentColor;
    IconData icon;

    if (type == 'error') {
      accentColor = const Color(0xFFD32F2F); // Merah Solid
      icon = Icons.cancel_rounded;
    } else { // warning
      accentColor = const Color(0xFFF59E0B); // Kuning Gelap Solid
      icon = Icons.info_rounded;
    }

    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        style: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87, // Judul Hitam Pekat
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black54, // Isi Abu Gelap (Kontras di Putih)
        ),
      ),
      snackPosition: SnackPosition.TOP,
      
      // TAMPILAN SOLID
      backgroundColor: Colors.white, 
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      
      // Indikator Warna di Kiri
      leftBarIndicatorColor: accentColor,
      
      icon: Icon(icon, color: accentColor, size: 28),
      shouldIconPulse: false,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15,
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