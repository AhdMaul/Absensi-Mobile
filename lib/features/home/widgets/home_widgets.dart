// lib/features/home/widgets/home_widgets.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTS ---
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/home_controller.dart'; // Import ActivityItem dari sini
import 'late_attendance_alert.dart';
import 'activity_tile.dart';
import '../../absensi/services/attendance_service.dart';

// --- MODELS (PINDAH KE CONTROLLER) ---
// ActivityItem sudah di-define di home_controller.dart

class DashboardData {
  final String userName;
  final String? todayCheckIn;
  final String? todayCheckOut;
  final bool isLate;
  final List<ActivityItem> recentActivities;

  DashboardData({
    this.userName = "Pengguna",
    this.todayCheckIn,
    this.todayCheckOut,
    this.isLate = false,
    this.recentActivities = const [],
  });
}

// --- WIDGET UTAMA ---
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with SingleTickerProviderStateMixin {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _isLoading = true;
  DashboardData _dashboardData = DashboardData();

  final AttendanceService _attendanceService = AttendanceService();

  // --- ANIMASI TOMBOL ---
  late AnimationController _btnController;
  late Animation<double> _iconScaleAnimation;

  // Warna
  final Color _actionButtonColor = const Color(0xFF00838F); // Deep Cyan

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    _fetchDashboardData();

    // Setup Animasi (Heartbeat untuk Icon)
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? "User";

      // 1. AMBIL DATA REAL
      final history = await _attendanceService.getHistory();

      String? checkInTime;
      String? checkOutTime;
      bool isLate = false;
      List<ActivityItem> activities = [];

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 2. Cari absen hari ini
      final todayAbsence = history.firstWhere((item) {
        final dateString = item['date'] ?? item['createdAt'];
        if (dateString == null) return false;
        final itemDate = DateTime.parse(dateString).toLocal();
        return DateFormat('yyyy-MM-dd').format(itemDate) == todayStr;
      }, orElse: () => null);

      if (todayAbsence != null) {
        if (todayAbsence['clockIn'] != null) {
          checkInTime = DateFormat(
            'HH:mm',
          ).format(DateTime.parse(todayAbsence['clockIn']).toLocal());

          final clockInDt = DateTime.parse(todayAbsence['clockIn']).toLocal();
          if (clockInDt.hour > 8 ||
              (clockInDt.hour == 8 && clockInDt.minute > 0))
            isLate = true;
        }
        if (todayAbsence['clockOut'] != null) {
          checkOutTime = DateFormat(
            'HH:mm',
          ).format(DateTime.parse(todayAbsence['clockOut']).toLocal());
        }
      }

      // 3. Mapping history
      if (history.isNotEmpty) {
        history.sort((a, b) {
          final dateA = a['date'] ?? a['createdAt'];
          final dateB = b['date'] ?? b['createdAt'];
          return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
        });

        activities = history.take(3).map<ActivityItem>((item) {
          final dateString = item['date'] ?? item['createdAt'];
          final date = DateTime.parse(dateString).toLocal();

          final inTime = item['clockIn'] != null
              ? DateFormat(
                  'HH:mm',
                ).format(DateTime.parse(item['clockIn']).toLocal())
              : '-';
          final outTime = item['clockOut'] != null
              ? DateFormat(
                  'HH:mm',
                ).format(DateTime.parse(item['clockOut']).toLocal())
              : '-';

          String statusText = item['status'] == 'late'
              ? 'Telat'
              : (item['status'] == 'present'
                    ? 'Tepat Waktu'
                    : item['status'] ?? '-');

          return ActivityItem(
            date: DateFormat('dd MMM').format(date),
            status: statusText,
            checkIn: inTime,
            checkOut: outTime,
          );
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _dashboardData = DashboardData(
          userName: userName,
          todayCheckIn: checkInTime,
          todayCheckOut: checkOutTime,
          isLate: isLate,
          recentActivities: activities,
        );
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetch dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA TOMBOL ABSEN ---
  Future<void> _handleAbsensiButton() async {
    // Cek Status Absensi Hari Ini
    bool alreadyCheckedIn = _dashboardData.todayCheckIn != null;
    bool alreadyCheckedOut = _dashboardData.todayCheckOut != null;

    // KONDISI 1: SUDAH SELESAI (Masuk & Pulang)
    if (alreadyCheckedIn && alreadyCheckedOut) {
      // Tampilkan Pesan Soft Spoken
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.sentiment_satisfied_alt_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Wah, kamu rajin banget! Istirahat dulu ya, lanjut lagi besok! ✨",
                  style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          // --- UBAH WARNA DI SINI ---
          // Sebelumnya: AppColors.neonCyan (Terlalu terang)
          // Sekarang: Deep Teal (Lebih tenang & profesional)
          backgroundColor: const Color(0xFF0F766E),

          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
      return; // Stop, jangan navigasi
    }

    // KONDISI 2: BELUM SELESAI -> Navigasi ke halaman Absen
    final result = await Navigator.pushNamed(context, AppRoutes.absensi);

    if (result != null && result is DateTime) {
      _fetchDashboardData(); // Refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading ? _buildSkeleton() : _buildContent(),
      ),
    );
  }

  // --- WIDGET: CONTENT UTAMA ---
  Widget _buildContent() {
    // Tentukan Teks Tombol berdasarkan status
    String buttonText = "Absen Masuk"; // Default
    IconData buttonIcon =
        Icons.face_retouching_natural; // Ikon default (Scan Wajah)

    if (_dashboardData.todayCheckIn != null) {
      if (_dashboardData.todayCheckOut == null) {
        buttonText = "Absen Pulang";
        buttonIcon = Icons.exit_to_app_rounded; // Ikon keluar
      } else {
        buttonText = "Selesai Hari Ini";
        buttonIcon = Icons.check_circle_outline_rounded; // Ikon selesai
      }
    }

    // Apakah tombol harus terlihat aktif atau "selesai"
    bool isCompleted =
        _dashboardData.todayCheckIn != null &&
        _dashboardData.todayCheckOut != null;

    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Nama
        Column(
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
              _dashboardData.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 2. Alert Telat
        if (_dashboardData.isLate) ...[
          const LateAttendanceAlert(
            message: "Anda telat hari ini. Jangan lupa disiplin besok ya!",
          ),
          const SizedBox(height: 20),
        ],

        // 3. Jam Real-time
        _buildClockCard(),

        const SizedBox(height: 20),

        // 4. TOMBOL ABSENSI UTAMA (DENGAN LOGIKA BARU)
        SizedBox(
          height: 64,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              // Jika sudah selesai, warnanya abu-abu biar user tau disable visual
              backgroundColor: isCompleted
                  ? Colors.grey.shade400
                  : _actionButtonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: isCompleted ? 0 : 4,
            ),
            onPressed: _handleAbsensiButton, // Panggil fungsi logika kita
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ANIMASI IKON (Hanya jika belum selesai)
                isCompleted
                    ? Icon(buttonIcon, size: 28) // Ikon diam jika selesai
                    : ScaleTransition(
                        scale: _iconScaleAnimation,
                        child: Icon(buttonIcon, size: 28),
                      ),

                const SizedBox(width: 12),

                Text(
                  buttonText,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // 5. Info Absen Masuk & Pulang
        Row(
          children: [
            _buildInfoCard(
              title: "Absen Masuk",
              time: _dashboardData.todayCheckIn ?? "--:--",
              icon: Icons.login_rounded,
              color: AppColors.neonGreen,
            ),
            const SizedBox(width: 16),
            _buildInfoCard(
              title: "Absen Pulang",
              time: _dashboardData.todayCheckOut ?? "--:--",
              icon: Icons.logout_rounded,
              color: AppColors.neonCyan,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 6. Header Aktivitas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Aktivitas Terkini",
              style: GoogleFonts.hankenGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.history);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: AppColors.neonCyan.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Lihat Semua",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonCyan.withValues(alpha: 1.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List Aktivitas
        _dashboardData.recentActivities.isEmpty
            ? const Center(child: Text("Belum ada aktivitas."))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dashboardData.recentActivities.length,
                itemBuilder: (context, index) {
                  return ActivityTile(
                    activity: _dashboardData.recentActivities[index],
                  );
                },
              ),

        const SizedBox(height: 20),
      ],
    );
  }

  // --- WIDGET: SKELETON LOADING ---
  Widget _buildSkeleton() {
    return Column(
      key: const ValueKey('loading'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSkeletonBox(width: 150, height: 20),
        const SizedBox(height: 8),
        _buildSkeletonBox(width: 200, height: 36),
        const SizedBox(height: 24),
        _buildClockCard(),
        const SizedBox(height: 20),
        _buildSkeletonBox(height: 68, radius: 20),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: _buildSkeletonBox(height: 130, radius: 16)),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonBox(height: 130, radius: 16)),
          ],
        ),
        const SizedBox(height: 32),
        _buildSkeletonBox(width: 180, height: 24),
        const SizedBox(height: 16),
        _buildSkeletonBox(height: 80, radius: 16),
        const SizedBox(height: 12),
        _buildSkeletonBox(height: 80, radius: 16),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildClockCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.buttonBlack.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, dd MMMM').format(_currentTime),
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('HH:mm:ss').format(_currentTime),
                style: GoogleFonts.hankenGrotesk(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Icon(
            Icons.access_time_filled_rounded,
            color: AppColors.neonGreen,
            size: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
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
            ),
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
      ),
    );
  }

  Widget _buildSkeletonBox({double? width, double? height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
