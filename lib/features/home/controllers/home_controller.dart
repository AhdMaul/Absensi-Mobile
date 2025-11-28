// lib/features/home/controllers/home_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../absensi/services/attendance_service.dart';

// --- MODELS ---
class ActivityItem {
  final String date;
  final String status;
  final String checkIn;
  final String checkOut;

  ActivityItem({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
  });
}

class DashboardData {
  final String userName;
  final String? lastCheckInTime;  
  final String? lastCheckOutTime; 
  final bool isLate;
  final bool isCurrentlyCheckedIn; 
  final List<ActivityItem> recentActivities;

  DashboardData({
    this.userName = "Pengguna",
    this.lastCheckInTime,
    this.lastCheckOutTime,
    this.isLate = false,
    this.isCurrentlyCheckedIn = false, 
    this.recentActivities = const [],
  });
}

class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  Timer? _clockTimer;

  // --- Reactive State ---
  final isLoading = true.obs;
  final currentTime = DateTime.now().obs;
  final dashboardData = DashboardData().obs;

  // --- Getters ---
  String get userName => dashboardData.value.userName;
  String? get todayCheckIn => dashboardData.value.lastCheckInTime;
  String? get todayCheckOut => dashboardData.value.lastCheckOutTime;
  bool get isLate => dashboardData.value.isLate;
  List<ActivityItem> get recentActivities => dashboardData.value.recentActivities;

  @override
  void onInit() {
    super.onInit();
    // Timer jam digital
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
    fetchDashboardData();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  // --- FUNGSI UTAMA: Tarik Data dari Backend ---
  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localName = prefs.getString('userName') ?? "User";

      final history = await _attendanceService.getHistory();

      bool lateStatus = false;
      bool currentlyCheckedIn = false;
      String? displayCheckIn;
      String? displayCheckOut;
      List<ActivityItem> activities = [];

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Filter Data HARI INI
      List<dynamic> todayRecords = history.where((item) {
         final dateString = item['date'] ?? item['createdAt'];
         if (dateString == null) return false;
         final itemDate = DateTime.parse(dateString).toLocal();
         return DateFormat('yyyy-MM-dd').format(itemDate) == todayStr;
      }).toList();

      // Urutkan Ascending (Sesi 1 -> Sesi Terakhir)
      todayRecords.sort((a, b) {
          final dateA = a['createdAt'] ?? a['date'];
          final dateB = b['createdAt'] ?? b['date'];
          return DateTime.parse(dateA).compareTo(DateTime.parse(dateB));
      });

      // Logika Status Absensi
      if (todayRecords.isNotEmpty) {
        // Cek telat dari record PERTAMA
        final firstRecord = todayRecords.first;
        final clockInDt = DateTime.parse(firstRecord['clockIn']).toLocal();
        
        if (firstRecord['status'] == 'late' || (clockInDt.hour > 8 || (clockInDt.hour == 8 && clockInDt.minute > 0))) {
           lateStatus = true;
        }

        // Cek record TERAKHIR untuk menentukan status tombol saat ini
        final lastRecord = todayRecords.last;
        
        if (lastRecord['clockIn'] != null) {
           displayCheckIn = DateFormat('HH:mm').format(DateTime.parse(lastRecord['clockIn']).toLocal());
        }
        
        if (lastRecord['clockOut'] != null) {
           // Sesi terakhir SUDAH ditutup (Clock Out)
           // Artinya user sedang "di luar" -> Siap untuk masuk lagi (Shift Baru/Lanjut)
           displayCheckOut = DateFormat('HH:mm').format(DateTime.parse(lastRecord['clockOut']).toLocal());
           currentlyCheckedIn = false; 
        } else {
           // Sesi terakhir BELUM ditutup (Masih null)
           // Artinya user sedang "kerja" -> Siap untuk Absen Pulang
           displayCheckOut = "--:--"; 
           currentlyCheckedIn = true; 
        }
      }

      // Mapping List Aktivitas
      if (history.isNotEmpty) {
        history.sort((a, b) {
            final dateA = a['createdAt'] ?? a['date'];
            final dateB = b['createdAt'] ?? b['date'];
            return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
        });

        activities = history.take(5).map<ActivityItem>((item) {
           final dateString = item['date'] ?? item['createdAt'];
           final date = DateTime.parse(dateString).toLocal();
           
           final inTime = item['clockIn'] != null ? DateFormat('HH:mm').format(DateTime.parse(item['clockIn']).toLocal()) : '-';
           final outTime = item['clockOut'] != null ? DateFormat('HH:mm').format(DateTime.parse(item['clockOut']).toLocal()) : '-';
           
           String statusText = item['status'] == 'late' ? 'Telat' : (item['status'] == 'present' ? 'Tepat Waktu' : item['status'] ?? '-');
           
           return ActivityItem(
             date: DateFormat('dd MMM').format(date),
             status: statusText,
             checkIn: inTime,
             checkOut: outTime,
           );
        }).toList();
      }

      dashboardData.value = DashboardData(
        userName: localName,
        lastCheckInTime: displayCheckIn,
        lastCheckOutTime: displayCheckOut,
        isLate: lateStatus,
        isCurrentlyCheckedIn: currentlyCheckedIn, 
        recentActivities: activities,
      );

    } catch (e) {
      debugPrint("Error fetching dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- LOGIKA TOMBOL ABSENSI (UPDATED) ---
  Map<String, dynamic> getActionButtonInfo() {
    String text;
    IconData icon;
    Color color;
    
    // Kita set false agar tombol TIDAK PERNAH mati (bisa multi-shift)
    bool isCompleted = false; 

    final isCurrentlyCheckedIn = dashboardData.value.isCurrentlyCheckedIn;
    final hasCheckIn = dashboardData.value.lastCheckInTime != null;
    final hasCheckOut = dashboardData.value.lastCheckOutTime != null;

    if (isCurrentlyCheckedIn) {
      // KONDISI 1: SEDANG KERJA (Tombol jadi 'Absen Pulang')
      text = "Absen Pulang";
      icon = Icons.logout_rounded;
      // Gunakan warna kontras untuk 'Stop/Keluar', misal Orange/Merah
      color = Colors.orange.shade800; 
    } else {
      // SEDANG TIDAK KERJA
      if (hasCheckIn && hasCheckOut) {
        // KONDISI 2: SUDAH PERNAH MASUK & KELUAR HARI INI (Re-entry)
        text = "Masuk Lagi"; 
        icon = Icons.update_rounded; // Icon refresh/cycle
        // Warna Ungu/Indigo sebagai penanda ini sesi tambahan
        color = const Color(0xFF6C63FF); 
      } else {
        // KONDISI 3: BELUM ADA ABSEN HARI INI (Fresh Start)
        text = "Absen Masuk";
        icon = Icons.login_rounded;
        color = AppColors.neonGreen; // Warna Hijau Fresh
      }
    }

    return {
      'text': text,
      'icon': icon,
      'color': color,
      'isCompleted': isCompleted,
    };
  }

  // --- Navigasi ke Absensi ---
  Future<void> navigateToAbsensi() async {
    final result = await Get.toNamed(AppRoutes.absensi);
    if (result != null) {
      fetchDashboardData();
    }
  }

  // --- FUNGSI YANG HILANG (DIKEMBALIKAN) ---
  void showWelcomeSnackbar() {
    Get.snackbar(
      'Selamat Datang',
      'Login berhasil! Selamat bekerja.',
      snackPosition: SnackPosition.TOP,
      // Gunakan background yang lebih lembut agar tidak terlalu kontras
      backgroundColor: AppColors.neonGreen.withValues(alpha: 0.18),
      // Teks yang lebih gelap agar terbaca pada background lembut
      colorText: AppColors.textPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      // Ikon diberi warna hijau neon yang sedikit lebih intens untuk aksen
      icon: Icon(
        Icons.check_circle,
        color: AppColors.neonGreen.withValues(alpha: 0.9),
      ),
      duration: const Duration(seconds: 3),
    );
  }
}