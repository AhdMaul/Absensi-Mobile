import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTS ---
import '../../../services/location_service.dart';
import '../../../config/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/api_base.dart'; // Untuk ApiException
import '../models/verification_result_model.dart';
import 'verify_face_widgets.dart'; 
import '../../absensi/services/attendance_service.dart';

class AbsenWidget extends StatefulWidget {
  const AbsenWidget({super.key});

  @override
  State<AbsenWidget> createState() => _AbsenWidgetState();
}

class _AbsenWidgetState extends State<AbsenWidget> {
  final _locationService = LocationService();
  final _attendanceService = AttendanceService();

  bool _isGettingLocation = false;
  bool _isLocationValid = false;
  String _locationMessage = 'Mulai cek lokasi Anda';
  double _distanceToOffice = -1.0;
  
  bool _showCameraStep = false;
  
  // Hasil Akhir
  String? _finalAbsensiMessage;
  // Color? _finalAbsensiColor; // (Unused field removed)
  Position? _currentPosition;

  DateTime _currentTime = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
       if (mounted) setState(() => _currentTime = DateTime.now());
    });
    // _loadUserId(); // (Unused function removed)
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    if (!mounted) return;
    setState(() {
      _isGettingLocation = true;
      _locationMessage = 'Sedang mendeteksi lokasi...';
      _isLocationValid = false;
      _showCameraStep = false;
      _finalAbsensiMessage = null;
      _currentPosition = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final distance = _locationService.getDistanceToOffice(
          position.latitude, position.longitude);
      final isValid = _locationService.isWithinOfficeRadius(distance);

      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _isLocationValid = isValid;
        _distanceToOffice = distance;
        _currentPosition = position;
        
        if (isValid) {
          _locationMessage = 'Lokasi Valid (${distance.toStringAsFixed(0)}m)';
          _showCameraStep = true; 
        } else {
          _locationMessage = 'Lokasi Jauh (${distance.toStringAsFixed(0)}m).\nMax radius: ${AppConstants.allowedRadiusMeters}m';
          _showCameraStep = false;
        }
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _locationMessage = 'Gagal deteksi lokasi. Pastikan GPS aktif.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.hankenGrotesk(color: AppColors.error, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.18),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      );
    }
  }

  void _onFaceVerified(VerificationResultModel result, DateTime captureTime) {
    final String formattedTime = DateFormat('HH:mm').format(captureTime);

    setState(() {
      _finalAbsensiMessage = "Absensi Berhasil!\nPukul $formattedTime";
      // _finalAbsensiColor = AppColors.neonGreen; // (Unused)
      _showCameraStep = false;
    });

    // Kirim data ke Backend
    _sendAttendanceData(captureTime);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context, captureTime); 
      }
    });
  }

  Future<void> _sendAttendanceData(DateTime captureTime) async {
    if (_currentPosition != null) {
      try {
        // --- PERBAIKAN PANGGILAN SERVICE ---
        // Menggunakan parameter terpisah, bukan model
        final response = await _attendanceService.submitAttendance(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          status: 'present',
          timestampForLog: captureTime,
        );
        
        // Gunakan debugPrint agar tidak warning avoid_print
        debugPrint("Data absensi terkirim. Response: ${response['message']}");
        
        if (mounted && response['message'] != null) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(
                 response['message'],
                 style: GoogleFonts.hankenGrotesk(color: AppColors.neonGreen, fontWeight: FontWeight.w600),
               ),
               backgroundColor: AppColors.neonGreen.withValues(alpha: 0.18),
               behavior: SnackBarBehavior.floating,
               margin: const EdgeInsets.all(16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 2,
             ),
           );
        }

      } on ApiException catch (e) {
        debugPrint("Gagal kirim data absensi: ${e.message}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message,
                style: GoogleFonts.hankenGrotesk(color: Colors.orange.shade700, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.orange.withValues(alpha: 0.18),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          );
        }
      } catch (e) {
        debugPrint("Error tak terduga: $e");
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error sistem: $e',
                style: GoogleFonts.hankenGrotesk(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.error.withValues(alpha: 0.18),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm').format(_currentTime),
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.0,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(_currentTime),
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        if (_finalAbsensiMessage != null)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neonGreen, width: 2),
              boxShadow: [
                BoxShadow(
                  // Perbaikan withValues
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  blurRadius: 20, offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 72),
                const SizedBox(height: 16),
                Text(
                  _finalAbsensiMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Mengalihkan ke beranda...",
                  style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              _buildStepCard(
                isActive: true,
                isCompleted: _isLocationValid,
                icon: Icons.location_on_rounded,
                title: "Deteksi Lokasi",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _locationMessage,
                            style: GoogleFonts.hankenGrotesk(
                              color: _isLocationValid ? AppColors.neonGreen : (_distanceToOffice > 0 ? AppColors.error : AppColors.textSecondary),
                              fontWeight: FontWeight.w600, fontSize: 14,
                            ),
                          ),
                        ),
                        if (_isGettingLocation)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                    if (!_isLocationValid && !_isGettingLocation)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonBlack,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: _checkLocation,
                            child: Text("Cek Lokasi Saya", style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              AnimatedOpacity(
                opacity: _showCameraStep ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 400),
                child: IgnorePointer(
                  ignoring: !_showCameraStep,
                  child: _buildStepCard(
                    isActive: _showCameraStep,
                    isCompleted: false,
                    icon: Icons.face_rounded,
                    title: "Verifikasi Wajah",
                    child: _showCameraStep
                        ? FaceVerificationStep(onVerificationSuccess: _onFaceVerified)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Selesaikan deteksi lokasi terlebih dahulu.",
                              style: GoogleFonts.hankenGrotesk(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStepCard({required bool isActive, required bool isCompleted, required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Perbaikan withValues
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? AppColors.neonGreen : (isActive ? AppColors.textPrimary : Colors.grey.shade200),
          width: isActive || isCompleted ? 1.5 : 1,
        ),
        boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // Perbaikan withValues
                  color: isCompleted ? AppColors.neonGreen.withValues(alpha: 0.1) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(isCompleted ? Icons.check_rounded : icon, color: isCompleted ? AppColors.neonGreen : AppColors.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}