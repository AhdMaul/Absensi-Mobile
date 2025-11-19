import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../../../core/routes/app_routes.dart'; 

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> login() async {
    // 1. Validasi Form
    if (!(formKey.currentState?.validate() ?? false)) return;

    // 2. Set loading state
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 3. Panggil API Login
      final response = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      // 4. Cek response sukses
      if (response.success) {
        // Navigate to home - SNACKBAR DIHAPUS dari sini
        // Akan ditampilkan di HomeScreen setelah build selesai
        Get.offNamed(AppRoutes.home, arguments: {'showWelcome': true});
      } else {
        // Tampilkan pesan error dari API
        errorMessage.value = response.message;
      }
    } catch (e) {
      // Handle error tak terduga
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      // Matikan loading state apa pun hasilnya
      isLoading.value = false;
    }
  }
  

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}