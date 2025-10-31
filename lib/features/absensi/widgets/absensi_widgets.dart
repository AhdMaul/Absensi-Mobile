// lib/features/face_recognition/widgets/absensi_widgets.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Pastikan import geolocator
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

// Import service, widget, model, konstanta
import '../../../services/location_service.dart';
import '../../../config/app_constants.dart'; 
import '../models/verification_result_model.dart';
import 'verify_face_widgets.dart'; 
import '../services/attendance_service.dart'; 


class AbsenWidget extends StatefulWidget {
  const AbsenWidget({super.key});

  @override
  State<AbsenWidget> createState() => _AbsenWidgetState();
}

class _AbsenWidgetState extends State<AbsenWidget> {
  // --- Services ---
  final _locationService = LocationService();
  final _attendanceService = AttendanceService();


  bool _isGettingLocation = false;
  bool _isLocationValid = false;
  String _locationMessage = 'Tekan tombol untuk cek lokasi';
  double _distanceToOffice = -1.0;
  bool _showCameraStep = false;
  String? _finalAbsensiMessage;
  MaterialColor? _finalAbsensiColor; // Ganti jadi Color? agar lebih fleksibel
  Position? _currentPosition;

  // --- State Waktu ---
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

   // --- User ID ---
  String? _userId;


  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (mounted) setState(() => _currentTime = DateTime.now());
    });
    _loadUserId(); // Muat User ID
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  // Fungsi load User ID
  Future<void> _loadUserId() async {
     final prefs = await SharedPreferences.getInstance();
     if (mounted) {
       setState(() {
         _userId = prefs.getString('userId');
       });
     }
  }

  // --- Fungsi Cek Lokasi ---
  Future<void> _checkLocation() async {
    if (!mounted) return;
    setState(() {
      _isGettingLocation = true;
      _locationMessage = 'Mendeteksi lokasi...';
      _isLocationValid = false;
      _showCameraStep = false;
      _finalAbsensiMessage = null;
      _currentPosition = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.getDistanceToOffice(position.latitude, position.longitude);
      final isValid = _locationService.isWithinOfficeRadius(distance);

      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _isLocationValid = isValid;
        _distanceToOffice = distance;
        _locationMessage = isValid
            ? '✅ Lokasi valid (${distance.toStringAsFixed(1)} m dari kantor)'
            : '❌ Lokasi tidak valid (${distance.toStringAsFixed(1)} m dari kantor).\nHarus dalam radius ${AppConstants.allowedRadiusMeters} m.';
        _showCameraStep = isValid;
        if (isValid) _currentPosition = position;
      });

      ScaffoldMessenger.of(context).showSnackBar( /* ... Snackbar Lokasi ... */ );

    } catch (e) {
      /* ... Error handling lokasi ... */
       if (!mounted) return;
       final errorMsg = 'Gagal cek lokasi: ${e.toString()}';
       setState(() { /* ... update state error ... */ });
       ScaffoldMessenger.of(context).showSnackBar( /* ... Snackbar error ... */ );
    }
  }

  // --- Callback dari FaceVerificationStep (Modifikasi) ---
  void _onFaceVerified(VerificationResultModel result, DateTime captureTime) async { // Jadikan async
    final String formattedTime = DateFormat('HH:mm:ss').format(captureTime);
    final String formattedDate = DateFormat('dd MMMM yyyy').format(captureTime);

    final finalMessage = "✅ Absensi Berhasil!\n"
                         "Waktu: $formattedTime ($formattedDate)\n"
                         "Lokasi: Valid, Wajah: Terverifikasi.";

    // Tampilkan pesan sukses dulu
    setState(() {
      _finalAbsensiMessage = finalMessage;
      _finalAbsensiColor = Colors.green; // Gunakan Color
      _showCameraStep = false; // Sembunyikan kamera
    });

    // Tampilkan Snackbar sukses
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(finalMessage),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
       ),
    );

    // Kirim data ke backend Express (tanpa menunggu selesai di UI)
    _sendAttendanceData(captureTime);


    // --- NAVIGASI KEMBALI KE HOME SETELAH DELAY ---
    Future.delayed(const Duration(seconds: 3), () { // Tunggu 3 detik
      if (mounted) {
        // Kembali ke halaman sebelumnya (Home) dan kirim waktu absen
        Navigator.pop(context, captureTime); // Kirim DateTime object
      }
    });
    // --- AKHIR NAVIGASI ---
  }

  // --- Fungsi terpisah untuk kirim data absensi ---
  Future<void> _sendAttendanceData(DateTime captureTime) async {
     if (_userId != null && _currentPosition != null) {
      try {
        print("Mengirim data absensi ke backend Express...");
        final attendanceResponse = await _attendanceService.submitAttendance(
          timestamp: captureTime,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        );
        print("Respon simpan absensi: ${attendanceResponse}");
      } catch (e) {
        print("Error saat mengirim data absensi: $e");
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal mengirim data absensi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } else {
       print("Error: User ID atau Posisi tidak valid saat mengirim data absensi.");
        // Mungkin tampilkan snackbar error pengiriman di sini juga
    }
  }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
     if (_userId == null && !_isGettingLocation) {
        /* ... Tampilkan error jika User ID null ... */
      }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Card Waktu Real-time ---
        Card( /* ... UI Jam ... */ ),

        // --- Tampilkan Hasil Absensi Akhir (jika sudah ada) ---
        if (_finalAbsensiMessage != null)
          Card(
            color: _finalAbsensiColor?.withOpacity(0.1) ?? Colors.grey.shade100,
            /* ... UI Card Hasil Akhir ... */
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon( Icons.check_circle, color: _finalAbsensiColor ?? Colors.green, size: 48,),
                  const SizedBox(height: 12),
                  Text(_finalAbsensiMessage!, /* ... style ... */),
                  const SizedBox(height: 16),
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(
                       'Kembali ke Beranda...',
                       style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                     ),
                   ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              // --- Card Lokasi (Langkah 1) ---
              Card( /* ... UI Card Lokasi ... */ ),

              // --- Bagian Verifikasi Wajah (Langkah 2) ---
              AnimatedOpacity(
                opacity: _showCameraStep ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Visibility(
                  visible: _showCameraStep,
                  child: FaceVerificationStep(
                    onVerificationSuccess: _onFaceVerified, // Pass callback
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 20),
      ],
    );
  }
}