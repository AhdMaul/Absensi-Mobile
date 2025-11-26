import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart'; // Untuk skeleton
import '../../../core/routes/app_routes.dart';
import 'late_attendance_alert.dart';

// Import Komponen yang sudah dipecah
import 'components/home_header.dart';
import 'components/realtime_clock_card.dart';
import 'components/attendance_action_button.dart';
import 'components/attendance_status_cards.dart';
import 'components/recent_activity_list.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      // 1. Skeleton Loading
      if (controller.isLoading.value) {
        return _buildSkeleton();
      }

      // Ambil info tombol
      final btnInfo = controller.getActionButtonInfo();

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Nama
            HomeHeader(userName: controller.userName),
            const SizedBox(height: 24),

            // Alert Telat
            if (controller.isLate) ...[
              const LateAttendanceAlert(
                message: "Anda telat hari ini. Jangan lupa disiplin besok ya!",
              ),
              const SizedBox(height: 20),
            ],

          // Jam Real-time
            RealtimeClockCard(currentTime: controller.currentTime.value),
            const SizedBox(height: 20),

            // Tombol Absensi (Animasi sudah di dalam widget ini)
            AttendanceActionButton(
              text: btnInfo['text'],
              icon: btnInfo['icon'],
              color: btnInfo['color'],
              isCompleted: btnInfo['isCompleted'],
              onPressed: controller.navigateToAbsensi,
            ),
            const SizedBox(height: 28),

            // Info Masuk/Pulang
            AttendanceStatusCards(
              checkInTime: controller.todayCheckIn,
              checkOutTime: controller.todayCheckOut,
            ),
            const SizedBox(height: 32),

            // Judul Aktivitas + tombol lihat semua
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Aktivitas Hari Ini",
                  style: TextStyle( // Atau pakai GoogleFonts
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary, // Pastikan import warna
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonCyan.withValues(alpha: 1.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // List Aktivitas
            RecentActivityList(activities: controller.recentActivities),
          ],
        ),
      );
    });
  }

  // Helper Skeleton (Bisa dipisah ke file sendiri juga jika mau)
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSkeletonBox(width: 150, height: 20),
          const SizedBox(height: 8),
          _buildSkeletonBox(width: 200, height: 36),
          const SizedBox(height: 24),
          _buildSkeletonBox(height: 100, radius: 16),
          const SizedBox(height: 20),
          _buildSkeletonBox(height: 64, radius: 20),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _buildSkeletonBox(height: 130, radius: 16)),
              const SizedBox(width: 16),
              Expanded(child: _buildSkeletonBox(height: 130, radius: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({double? width, double? height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}