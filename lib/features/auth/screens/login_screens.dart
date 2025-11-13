// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/login_form.dart'; // <-- IMPORT WIDGET BARU
import '../widgets/login_header.dart'; // <-- IMPORT WIDGET BARU
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get existing controller or create new one (safe version)
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoginHeader(),
                const SizedBox(height: 40),

                // Wrap LoginForm with Obx so it rebuilds on reactive changes
                Obx(() => LoginForm(
                      formKey: controller.formKey,
                      emailController: controller.emailController,
                      passwordController: controller.passwordController,
                      isLoading: controller.isLoading.value,
                      errorMessage: controller.errorMessage.value,
                      onLoginPressed: controller.login,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}