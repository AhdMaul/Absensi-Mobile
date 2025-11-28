import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_buttons.dart'; 
import '../controllers/auth_controller.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  final controller = Get.find<AuthController>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Sedikit diperlambat agar smooth
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil padding keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // Material digunakan agar child memiliki style material yang benar
    // Dismissible ditambahkan agar user bisa swipe ke bawah untuk menutup (Gestur native)
    return Material(
      color: Colors.transparent,
      child: Dismissible(
        key: const Key('login_sheet'),
        direction: DismissDirection.down, // Swipe ke bawah untuk tutup
        onDismissed: (_) => Navigator.of(context).pop(),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              )
            ],
          ),
          child: SingleChildScrollView(
            // Physics bouncing agar terasa organik saat mentok scroll
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Drag Handle
                  _buildAnimatedItem(
                    index: 0,
                    child: Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // 2. Title
                  _buildAnimatedItem(
                    index: 1,
                    child: Text(
                      'Welcome Back!',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // 3. Subtitle
                  _buildAnimatedItem(
                    index: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      child: Text(
                        'Please enter your details to continue.',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 14, color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // 4. Email Input
                  _buildAnimatedItem(
                    index: 3,
                    child: _buildInput(
                      controller: controller.emailController,
                      label: 'Company Email',
                      icon: Icons.alternate_email_rounded,
                      inputType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Password Input
                  _buildAnimatedItem(
                    index: 4,
                    child: _buildInput(
                      controller: controller.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Login Button
                  _buildAnimatedItem(
                    index: 5, // Index diperbaiki agar urut
                    child: Obx(
                      () => PremiumDarkButton(
                        text: 'Log In',
                        isLoading: controller.isLoading.value,
                        onPressed: () => controller.login(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// UPGRADED ANIMATION: Slide + Fade + Scale (Pop Effect)
  Widget _buildAnimatedItem({required int index, required Widget child}) {
    // Delay sedikit lebih cepat agar responsif
    final double beginInterval = index * 0.05; 
    final double endInterval = beginInterval + 0.5;

    final clampedBegin = beginInterval.clamp(0.0, 1.0);
    final clampedEnd = endInterval.clamp(0.0, 1.0);

    final curve = Curves.easeOutBack; // Memberikan sedikit overshoot (membal)

    // 1. Animasi Slide (Naik dari bawah)
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Jarak slide diperpendek agar lebih "tight"
      end: Offset.zero
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(clampedBegin, clampedEnd, curve: curve),
      ),
    );

    // 2. Animasi Fade (Muncul transparan)
    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(clampedBegin, clampedEnd, curve: Curves.easeOut),
      ),
    );

    // 3. Animasi Scale (Membesar - Efek Pop)
    final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(clampedBegin, clampedEnd, curve: curve),
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition( // Tambahan Scale Transition
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? inputType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        style: GoogleFonts.hankenGrotesk(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.hankenGrotesk(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}