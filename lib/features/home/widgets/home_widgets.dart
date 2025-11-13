import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  DateTime? _lastAttendanceTime;

  @override
  void initState() {
    super.initState();
    _loadLastAttendance();
  }

  Future<void> _loadLastAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTime = prefs.getString('lastAttendanceTime');
    if (storedTime != null) {
      setState(() {
        _lastAttendanceTime = DateTime.tryParse(storedTime);
      });
    }
  }

  Future<void> _saveLastAttendance(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastAttendanceTime', time.toIso8601String());
    setState(() {
      _lastAttendanceTime = time;
    });
  }

  Future<void> _navigateToAbsensi() async {
    final result = await Navigator.pushNamed(context, AppRoutes.absensi);

    if (result != null && result is DateTime) {
      await _saveLastAttendance(result);

      final formatted = DateFormatter.formatTime(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Absensi berhasil pada $formatted')),
      );
    }
  }

  String _getFormattedAttendance() {
    if (_lastAttendanceTime == null) {
      return "Belum ada data absensi.";
    }

    final date = DateFormatter.formatFullDate(_lastAttendanceTime!);
    final time = DateFormatter.formatTime(_lastAttendanceTime!);
    return "🕒 $time — $date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Absensi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selamat Datang 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // CARD JAM ABSEN
            Card(
              elevation: 3,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const Text(
                      'Absen Masuk Terakhir',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getFormattedAttendance(),
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // TOMBOL ABSENSI
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _navigateToAbsensi,
              icon: const Icon(Icons.fingerprint, size: 28),
              label: const Text(
                "Mulai Absensi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
