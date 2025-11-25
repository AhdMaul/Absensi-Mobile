import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../absensi/services/attendance_service.dart';

// Models
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

class HomeController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  Timer? _clockTimer;

  // --- Rx Variables (Reactive State) ---
  final isLoading = true.obs;
  final currentTime = DateTime.now().obs;
  final dashboardData = DashboardData().obs;

  // --- Getters untuk convenience ---
  String get userName => dashboardData.value.userName;
  String? get todayCheckIn => dashboardData.value.todayCheckIn;
  String? get todayCheckOut => dashboardData.value.todayCheckOut;
  bool get isLate => dashboardData.value.isLate;
  List<ActivityItem> get recentActivities =>
      dashboardData.value.recentActivities;

  // --- Tombol state ---
  final isAbsensiButtonEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    Intl.defaultLocale = 'id_ID';

    // Start real-time clock
    _startClockTimer();

    // Fetch dashboard data on init
    fetchDashboardData();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  // --- Clock Timer (Real-time) ---
  void _startClockTimer() {
    try {
      _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        try {
          if (isLoading.value == false) {
            currentTime.value = DateTime.now();
          }
        } catch (e) {
          debugPrint("⚠️ ERROR updating clock: $e");
        }
      });
    } catch (e) {
      debugPrint("❌ ERROR starting clock timer: $e");
    }
  }

  // --- Helper: Safe DateTime Parsing ---
  DateTime? _safeParseDateTime(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString.toString()).toLocal();
    } catch (e) {
      debugPrint("❌ ERROR parsing date: $dateString -> $e");
      return null;
    }
  }

  // --- Helper: Safe Format DateTime to HH:mm ---
  String _formatTimeString(dynamic dateString) {
    try {
      final dt = _safeParseDateTime(dateString);
      if (dt == null) return '-';
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      debugPrint("❌ ERROR formatting time: $e");
      return '-';
    }
  }

  // --- Helper: Safe Format DateTime to dd MMM ---
  String _formatDateString(dynamic dateString) {
    try {
      final dt = _safeParseDateTime(dateString);
      if (dt == null) return '-';
      return DateFormat('dd MMM').format(dt);
    } catch (e) {
      debugPrint("❌ ERROR formatting date: $e");
      return '-';
    }
  }

  // --- Fetch Dashboard Data ---
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      debugPrint("🔄 [HomeController] Starting fetchDashboardData...");

      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? "User";
      debugPrint("✓ Username: $userName");

      // 1. Get attendance history
      debugPrint("📡 [HomeController] Calling getHistory()...");
      final history = await _attendanceService.getHistory();
      debugPrint("✓ History returned: ${history.length} items");

      String? checkInTime;
      String? checkOutTime;
      bool isLate = false;
      List<ActivityItem> activities = [];

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      debugPrint("📅 Today: $todayStr");

      // 2. Find today's attendance
      if (history.isNotEmpty) {
        try {
          final todayAbsence = history.firstWhere((item) {
            try {
              final dateString = item['date'] ?? item['createdAt'];
              if (dateString == null) return false;
              final itemDate = _safeParseDateTime(dateString);
              if (itemDate == null) return false;
              return DateFormat('yyyy-MM-dd').format(itemDate) == todayStr;
            } catch (e) {
              debugPrint("⚠️ ERROR checking date for item: $e");
              return false;
            }
          }, orElse: () => null);

          if (todayAbsence != null) {
            debugPrint("✓ Found today's attendance record");
            if (todayAbsence['clockIn'] != null) {
              checkInTime = _formatTimeString(todayAbsence['clockIn']);
              debugPrint("✓ Check-in time: $checkInTime");

              final clockInDt = _safeParseDateTime(todayAbsence['clockIn']);
              if (clockInDt != null) {
                if (clockInDt.hour > 8 ||
                    (clockInDt.hour == 8 && clockInDt.minute > 0)) {
                  isLate = true;
                  debugPrint("⚠️ Marked as LATE");
                }
              }
            }
            if (todayAbsence['clockOut'] != null) {
              checkOutTime = _formatTimeString(todayAbsence['clockOut']);
              debugPrint("✓ Check-out time: $checkOutTime");
            }
          } else {
            debugPrint("ℹ️ No attendance record for today");
          }
        } catch (e) {
          debugPrint("❌ ERROR processing today's attendance: $e");
        }

        // 3. Map history to activity items
        try {
          history.sort((a, b) {
            try {
              final dateA = a['date'] ?? a['createdAt'];
              final dateB = b['date'] ?? b['createdAt'];
              final dtA = _safeParseDateTime(dateA);
              final dtB = _safeParseDateTime(dateB);
              if (dtA == null || dtB == null) return 0;
              return dtB.compareTo(dtA);
            } catch (e) {
              debugPrint("⚠️ ERROR sorting: $e");
              return 0;
            }
          });

          activities = history.take(3).map<ActivityItem>((item) {
            try {
              final dateString = item['date'] ?? item['createdAt'];
              final formattedDate = _formatDateString(dateString);

              final inTime = item['clockIn'] != null
                  ? _formatTimeString(item['clockIn'])
                  : '-';
              final outTime = item['clockOut'] != null
                  ? _formatTimeString(item['clockOut'])
                  : '-';

              String statusText = (item['status'] ?? '').toString().toLowerCase();
              if (statusText == 'late') {
                statusText = 'Telat';
              } else if (statusText == 'present') {
                statusText = 'Tepat Waktu';
              } else {
                statusText = statusText.isNotEmpty ? statusText : '-';
              }

              return ActivityItem(
                date: formattedDate,
                status: statusText,
                checkIn: inTime,
                checkOut: outTime,
              );
            } catch (e) {
              debugPrint("❌ ERROR mapping activity item: $e");
              return ActivityItem(
                date: '-',
                status: '-',
                checkIn: '-',
                checkOut: '-',
              );
            }
          }).toList();
          debugPrint("✓ Mapped ${activities.length} activity items");
        } catch (e) {
          debugPrint("❌ ERROR mapping history: $e");
        }
      } else {
        debugPrint("ℹ️ History is empty");
      }

      // 4. Update state
      dashboardData.value = DashboardData(
        userName: userName,
        todayCheckIn: checkInTime,
        todayCheckOut: checkOutTime,
        isLate: isLate,
        recentActivities: activities,
      );

      isLoading.value = false;
      debugPrint("✅ [HomeController] fetchDashboardData completed successfully");
    } catch (e, stackTrace) {
      debugPrint("❌ [HomeController] FATAL ERROR fetch dashboard: $e");
      debugPrintStack(stackTrace: stackTrace);
      isLoading.value = false;
    }
  }

  // --- Handle Absensi Button ---
  Future<void> handleAbsensiButton() async {
    bool alreadyCheckedIn = todayCheckIn != null;
    bool alreadyCheckedOut = todayCheckOut != null;

    // CASE 1: Already checked in & out
    if (alreadyCheckedIn && alreadyCheckedOut) {
      Get.snackbar(
        'Selesai',
        'Wah, kamu rajin banget! Istirahat dulu ya, lanjut lagi besok! ✨',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F766E),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.sentiment_satisfied_alt_rounded,
            color: Colors.white),
      );
      return;
    }

    // CASE 2: Navigate to absensi screen
    isAbsensiButtonEnabled.value = false;
    final result = await Get.toNamed(AppRoutes.absensi);
    isAbsensiButtonEnabled.value = true;

    if (result != null && result is DateTime) {
      await fetchDashboardData(); // Refresh data
    }
  }

  // --- Get button display info ---
  Map<String, dynamic> getAbsensiButtonInfo() {
    String text = "Absen Masuk";
    IconData icon = Icons.face_retouching_natural;

    if (todayCheckIn != null) {
      if (todayCheckOut == null) {
        text = "Absen Pulang";
        icon = Icons.exit_to_app_rounded;
      } else {
        text = "Selesai Hari Ini";
        icon = Icons.check_circle_outline_rounded;
      }
    }

    bool isCompleted = todayCheckIn != null && todayCheckOut != null;

    return {
      'text': text,
      'icon': icon,
      'isCompleted': isCompleted,
    };
  }

  // --- Logout ---
  Future<void> logout() async {
    try {
      await Get.defaultDialog(
        title: 'Konfirmasi Logout',
        content: const Text('Apakah Anda yakin ingin logout?'),
        onConfirm: () async {
          Get.back();
          // Panggil logout dari service
          // await _authService.logout();
          Get.offAllNamed(AppRoutes.login);
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      debugPrint("Error logout: $e");
    }
  }

  // --- Helper: Show success snackbar ---
  void showWelcomeSnackbar() {
    Get.snackbar(
      'Selamat Datang',
      'Login berhasil! Selamat bekerja.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.neonGreen.withValues(alpha: 0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}
