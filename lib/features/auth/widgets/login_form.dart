// lib/features/auth/widgets/login_form.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; // Sesuaikan path jika perlu

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onLoginPressed;
  // final VoidCallback onRegisterTap; // Opsional jika ada halaman register
  // final VoidCallback onFaceVerifyTap; // Opsional jika ada verifikasi wajah

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onLoginPressed,
    // required this.onRegisterTap,
    // required this.onFaceVerifyTap,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // TextFormField akan otomatis menggunakan style dari app_theme.dart
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
              // Style (border, color, font) diambil dari app_theme.dart
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Format email tidak valid';
              }
              return null; // Valid
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
                // Icon color akan otomatis diatur oleh prefixIconColor di theme
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              // Style (border, color, font) diambil dari app_theme.dart
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
                style: const TextStyle(color: kErrorColor),
                textAlign: TextAlign.center,
              ),
            ),

          // --- Tombol Login ---
          widget.isLoading
              ? const Center(child: CircularProgressIndicator(color: kPrimaryRed))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRed, // Warna utama
                    foregroundColor: Colors.white, // Warna teks
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: widget.onLoginPressed,
                  child: const Text('LOGIN'),
                ),
          const SizedBox(height: 20),

          // --- Link Tambahan (Opsional) ---
          Center(
            child: Text.rich(
              TextSpan(
                text: 'Belum punya akun? ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kTextColor.withOpacity(0.7),
                    ),
                children: [
                  TextSpan(
                    text: 'Daftar di sini',
                    style: const TextStyle(
                      color: kPrimaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Panggil widget.onRegisterTap
                        // Navigator.pushNamed(context, '/register');
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