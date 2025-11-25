// lib/features/home/widgets/home_content.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'late_attendance_alert.dart';
import 'activity_tile.dart';

/// Main home content widget - uses HomeController via Obx for reactivity
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Obx(() {
      // Show skeleton while loading
      if (homeController.isLoading.value) {
        return _buildSkeleton();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Greeting with user name
            _buildGreeting(homeController),
            const SizedBox(height: 16),

            // 2. Late alert (if applicable)
            if (homeController.isLate) ...[
              const LateAttendanceAlert(
                message:
                    "Anda telat hari ini. Jangan lupa disiplin besok ya!",
              ),
              const SizedBox(height: 16),
            ],

            // 3. Real-time clock
            _buildClockCard(homeController),
            const SizedBox(height: 20),

            // 4. Main attendance button
            _buildAttendanceButton(homeController),
            const SizedBox(height: 24),

            // 5. Check-in / Check-out cards
            _buildCheckInOutCards(homeController),
            const SizedBox(height: 24),

            // 6. Recent activities
            _buildRecentActivities(homeController),
          ],
        ),
      );
    });
  }

  Widget _buildGreeting(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang,',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildClockCard(HomeController controller) {
    return Obx(() {
      final now = controller.currentTime.value;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.buttonBlack.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd MMMM').format(now),
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('HH:mm:ss').format(now),
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Icon(Icons.access_time_filled_rounded,
                color: AppColors.neonGreen, size: 36),
          ],
        ),
      );
    });
  }

  Widget _buildAttendanceButton(HomeController controller) {
    return Obx(() {
      final btnInfo = controller.getAbsensiButtonInfo();
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBlack,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: 0.12),
        ),
        onPressed: controller.isAbsensiButtonEnabled.value
            ? () => controller.handleAbsensiButton()
            : null,
        icon: Icon(btnInfo['icon'] as IconData, size: 28),
        label: Text(
          btnInfo['text'] as String,
          style: GoogleFonts.hankenGrotesk(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    });
  }

  Widget _buildCheckInOutCards(HomeController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            title: "Absen Masuk",
            time: controller.todayCheckIn ?? "--:--",
            icon: Icons.login_rounded,
            color: AppColors.neonGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            title: "Absen Pulang",
            time: controller.todayCheckOut ?? "--:--",
            icon: Icons.logout_rounded,
            color: AppColors.neonCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            time,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Aktivitas Terkini",
          style: GoogleFonts.hankenGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (controller.recentActivities.isEmpty)
          const Center(child: Text("Belum ada aktivitas."))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentActivities.length,
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return ActivityTile(activity: activity);
            },
          ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
