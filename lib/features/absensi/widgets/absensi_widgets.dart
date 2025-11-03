import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

// Import service, widget, model, konstanta
import '../../../services/location_service.dart';
import '../../../config/app_constants.dart';
import '../models/verification_result_model.dart';
// Import widget baru (anak)
import '../widgets/verify_face_widgets.dart';

class AbsenWidget extends StatefulWidget {
  const AbsenWidget({super.key});

  @override
  State<AbsenWidget> createState() => _AbsenWidgetState();
}

class _AbsenWidgetState extends State<AbsenWidget> {
  // --- Services ---
  final _locationService = LocationService();

  // --- State UI ---
  bool _isGettingLocation = false;
  bool _isLocationValid = false;
  String _locationMessage = 'Tekan tombol untuk cek lokasi';
  double _distanceToOffice = -1.0;
  bool _showCameraStep = false; // Tampilkan Langkah 2 (wajah) jika lokasi valid
  String? _finalAbsensiMessage; // Pesan hasil absensi akhir (sukses/gagal)
  Color? _finalAbsensiColor; // Warna card hasil akhir

  // --- State Waktu ---
  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  // --- Fungsi Cek Lokasi ---
  Future<void> _checkLocation() async {
    if (!mounted) return;
    setState(() {
      _isGettingLocation = true;
      _locationMessage = 'Mendeteksi lokasi...';
      _isLocationValid = false;
      _showCameraStep = false; // Sembunyikan langkah 2
      _finalAbsensiMessage = null; // Reset hasil akhir
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
        _showCameraStep = isValid; // Tampilkan Langkah 2 jika lokasi valid
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLocationValid
              ? 'Lokasi sesuai, silakan lanjut ambil foto wajah.'
              : _locationMessage),
          backgroundColor: _isLocationValid ? Colors.blueAccent : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMsg = 'Gagal cek lokasi: ${e.toString()}';
      setState(() {
        _isGettingLocation = false;
        _isLocationValid = false;
        _showCameraStep = false;
        _locationMessage = errorMsg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  // --- Callback dari FaceVerificationStep ---
  void _onFaceVerified(VerificationResultModel result, DateTime captureTime) {
    final String formattedTime = DateFormat('HH:mm:ss').format(captureTime);
    final String formattedDate = DateFormat('dd MMMM yyyy').format(captureTime);

    final finalMessage = "✅ Absensi Berhasil!\n"
        "Waktu: $formattedTime ($formattedDate)\n"
        "Lokasi: Valid, Wajah: Terverifikasi.";

    setState(() {
      _finalAbsensiMessage = finalMessage;
      _finalAbsensiColor = Colors.green;
      _showCameraStep = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Absensi berhasil disimpan.'),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ Kirim hasil waktu absensi ke HomeWidget
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, captureTime); // <<=== Kunci utama koneksi
    });
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Karyawan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Card Waktu Real-time ---
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  children: [
                    Text(DateFormat('EEEE, dd MMMM yyyy').format(_currentTime)),
                    const SizedBox(height: 4),
                    Text(DateFormat('HH:mm:ss').format(_currentTime),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            // --- Tampilkan Hasil Absensi Akhir (jika sudah ada) ---
            if (_finalAbsensiMessage != null)
              Card(
                color: _finalAbsensiColor?.withOpacity(0.1) ?? Colors.grey.shade100,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _finalAbsensiColor ?? Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _finalAbsensiMessage!,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _finalAbsensiColor ?? Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // --- Card Lokasi (Langkah 1) ---
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Langkah 1: Validasi Lokasi Anda',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(
                                _isLocationValid ? Icons.check_circle : Icons.location_on_outlined,
                                color: _isLocationValid
                                    ? Colors.green
                                    : (_distanceToOffice == -1.0 ? Colors.grey : Colors.red),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_locationMessage)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _isGettingLocation
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: LinearProgressIndicator(),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Validasi Lokasi Saya'),
                                  onPressed: _checkLocation,
                                ),
                        ],
                      ),
                    ),
                  ),

                  // --- Bagian Verifikasi Wajah (Langkah 2) ---
                  AnimatedOpacity(
                    opacity: _showCameraStep ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Visibility(
                      visible: _showCameraStep,
                      child: FaceVerificationStep(
                        onVerificationSuccess: _onFaceVerified,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
