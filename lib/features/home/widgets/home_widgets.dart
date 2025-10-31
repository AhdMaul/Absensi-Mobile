// lib/features/home/widgets/home_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../../../core/routes/app_routes.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  String userName = "Pengguna";
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  DateTime? _lastAttendanceTime; // State untuk menyimpan waktu absen terakhir

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    // _loadUserData();
    _loadLastAttendanceTime(); // Muat waktu absen terakhir dari SharedPreferences

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLastAttendanceTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('lastAttendanceTime');
    if (timestamp != null && mounted) {
      setState(() {
        _lastAttendanceTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      });
    }
  }


  Future<void> _saveLastAttendanceTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastAttendanceTime', time.millisecondsSinceEpoch);
  }


  // --- Modifikasi Navigasi ke Absen ---
  void _goToAbsenScreen() async {
    // Navigasi ke halaman Absen dan tunggu hasilnya
    final result = await Navigator.pushNamed(context, AppRoutes.absensi);

    // Cek hasil yang dikembalikan dari Navigator.pop() di AbsenWidget
    if (result != null && result is DateTime && mounted) {
      setState(() {
        _lastAttendanceTime = result; // Update state dengan waktu absen baru
      });
      // Simpan waktu absen baru ke SharedPreferences
      await _saveLastAttendanceTime(result);
    }
  }
  // --- Akhir Modifikasi Navigasi ---

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Waktu Real-time ---
            Text(DateFormat('EEEE, dd MMMM yyyy').format(_currentTime), /* ... style ... */),
            const SizedBox(height: 8),
            Text(DateFormat('HH:mm:ss').format(_currentTime), /* ... style ... */),
            const SizedBox(height: 30), // Kurangi sedikit jarak

            // --- Tampilkan Waktu Absen Terakhir (Jika Ada) ---
            if (_lastAttendanceTime != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Agar Row tidak full width
                    children: [
                      Icon(Icons.access_time_filled, color: Colors.green.shade700, size: 20,),
                      const SizedBox(width: 8),
                      Text(
                        'Absen Masuk: ${DateFormat('HH:mm').format(_lastAttendanceTime!)}', // Format jam:menit
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ] else ... [
               const Text('Anda belum melakukan absensi masuk hari ini.', style: TextStyle(color: Colors.grey)),
               const SizedBox(height: 30),
            ],

            Text('Selamat Datang, $userName!', /* ... style ... */),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              icon: const Icon(Icons.sensor_occupied_rounded),
              label: const Text('Mulai Absensi'),
              style: ElevatedButton.styleFrom( /* ... style ... */ ),
              onPressed: _goToAbsenScreen,
            ),
          ],
        ),
      ),
    );
  }
}