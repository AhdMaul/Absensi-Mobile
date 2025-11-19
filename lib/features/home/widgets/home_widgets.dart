// lib/features/home/widgets/home_widgets.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
// Import widget alert baru
import 'late_attendance_alert.dart';

// Model sederhana untuk data dashboard (ganti dengan model aslimu)
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

class ActivityItem {
  final String date;
  final String status; // Misal: "Tepat Waktu", "Telat", "Pulang Cepat"
  final String checkIn;
  final String checkOut;

  ActivityItem({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
  });
}


class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  bool _isLoading = true;
  DashboardData _dashboardData = DashboardData();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    
    // Panggil fungsi untuk mengambil data dashboard
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- FUNGSI PENGAMBIL DATA (Perlu Backend) ---
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    
    // == PERLU BACKEND ==
    // Panggil service untuk ambil data dashboard (misal: AttendanceService.getDashboard())
    // Service ini harus mengembalikan:
    // 1. Nama User
    // 2. Absen Masuk Hari Ini (jika ada)
    // 3. Absen Keluar Hari Ini (jika ada)
    // 4. Status Telat Hari Ini (boolean)
    // 5. List 3-5 aktivitas terakhir
    
    // --- Data Palsu (HAPUS JIKA BACKEND SIAP) ---
    await Future.delayed(const Duration(seconds: 1)); // Simulasi loading
    final prefs = await SharedPreferences.getInstance();
    final lastAttendanceTime = prefs.getString('lastAttendanceTime');
    
    setState(() {
      _dashboardData = DashboardData(
        userName: "Deswita", // Ganti dengan data user asli
        // Cek dari SharedPreferences (data palsu)
        todayCheckIn: lastAttendanceTime != null 
            ? DateFormat('HH:mm').format(DateTime.parse(lastAttendanceTime)) 
            : null, 
        todayCheckOut: null, // Contoh belum absen pulang
        isLate: true, // Contoh jika telat
        recentActivities: [
          ActivityItem(date: "Kemarin, 17 Nov", status: "Tepat Waktu", checkIn: "08:00", checkOut: "17:00"),
          ActivityItem(date: "Jumat, 14 Nov", status: "Telat (08:15)", checkIn: "08:15", checkOut: "17:01"),
          ActivityItem(date: "Kamis, 13 Nov", status: "Tepat Waktu", checkIn: "07:55", checkOut: "17:05"),
        ]
      );
      _isLoading = false;
    });
    // --- Akhir Data Palsu ---
  }

  // Navigasi ke halaman Absen
  Future<void> _navigateToAbsensi() async {
    final result = await Navigator.pushNamed(context, AppRoutes.absensi);

    if (result != null && result is DateTime) {
      // Jika absensi berhasil, data dashboard perlu di-refresh
      _fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 1. Ucapan Selamat Datang ---
          Text(
            'Selamat Datang,',
            style: GoogleFonts.hankenGrotesk( //
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            _dashboardData.userName,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // --- 2. Alert Telat (Sesuai Referensi) ---
          if (_dashboardData.isLate) ...[
            const LateAttendanceAlert(
              message: "Anda telat hari ini. Jangan lupa disiplin besok ya!",
            ),
            const SizedBox(height: 16),
          ],
          
          // --- 3. Jam Real-time ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.buttonBlack.withOpacity(0.9), //
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
                Icon(Icons.access_time_filled_rounded, color: AppColors.neonGreen, size: 36), //
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- 4. Tombol Absensi Utama ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBlack, //
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.2),
            ),
            onPressed: _navigateToAbsensi,
            icon: const Icon(Icons.sensor_occupied_rounded, size: 28),
            label: Text(
              "Mulai Absensi",
              style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          
          // --- 5. Info Absen Masuk & Pulang Hari Ini ---
          Row(
            children: [
              _buildInfoCard(
                title: "Absen Masuk",
                time: _dashboardData.todayCheckIn ?? "--:--",
                icon: Icons.login_rounded,
                color: AppColors.neonGreen, //
              ),
              const SizedBox(width: 16),
              _buildInfoCard(
                title: "Absen Pulang",
                time: _dashboardData.todayCheckOut ?? "--:--",
                icon: Icons.logout_rounded,
                color: AppColors.neonCyan, //
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- 6. Aktivitas Terkini (Riwayat) ---
          Text(
            "Aktivitas Terkini",
            style: GoogleFonts.hankenGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Tampilkan list riwayat
          _dashboardData.recentActivities.isEmpty
          ? const Center(child: Text("Belum ada aktivitas."))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Agar bisa di-scroll oleh SingleChildScrollView
              itemCount: _dashboardData.recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _dashboardData.recentActivities[index];
                return _buildActivityTile(activity);
              },
            ),
            
           const SizedBox(height: 20), // Spasi di akhir
        ],
      ),
    );
  }

  // --- Helper Widget untuk Kartu Info (Masuk/Pulang) ---
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
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.03),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ]
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

  // --- Helper Widget untuk Riwayat Aktivitas ---
  Widget _buildActivityTile(ActivityItem activity) {
     final bool isLate = activity.status.toLowerCase().contains("telat");
     final Color statusColor = isLate ? Colors.orange.shade800 : Colors.green.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.date,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${activity.checkIn} - ${activity.checkOut}",
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              activity.status,
              style: GoogleFonts.hankenGrotesk(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}