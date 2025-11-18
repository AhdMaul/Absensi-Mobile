// lib/features/auth/widgets/login_form.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onLoginPressed;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onLoginPressed,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Input Email ---
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(
              labelText: 'Email Perusahaan',
              prefixIcon: Icon(Icons.alternate_email),
              // Style border & font otomatis diambil dari theme
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // --- Input Password ---
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // --- Pesan Error ---
          if (widget.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.errorMessage,
                style: const TextStyle(
                  color: AppColors.error, // SUDAH DIPERBAIKI
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // --- Tombol Login ---
          widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonBlack, // SUDAH DIPERBAIKI
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBlack, // SUDAH DIPERBAIKI (Hitam)
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Dibuat lebih bulat (Pill shape)
                    ),
                  ),
                  onPressed: widget.onLoginPressed,
                  child: const Text(
                    'Log In', // Teks disesuaikan sedikit agar lebih clean
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(height: 20),

          // --- Link Tambahan ---
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Belum punya akun? ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary.withOpacity(0.7), // SUDAH DIPERBAIKI
                    ),
                children: [
                  TextSpan(
                    text: 'Daftar di sini',
                    style: const TextStyle(
                      color: AppColors.buttonBlack, // Menggunakan hitam agar konsisten
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Menuju halaman daftar...')),
                        );
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}