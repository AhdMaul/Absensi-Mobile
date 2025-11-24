// lib/features/absensi/widgets/verify_face_widgets.dart

import 'dart:async';
import 'dart:ui' as ui; // IMPORT WAJIB UNTUK PATH METRICS
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

import '../services/face_recognition_service.dart';
import 'camera_widget.dart';
import '../models/verification_result_model.dart';

class FaceVerificationStep extends StatefulWidget {
  final Function(VerificationResultModel result, DateTime captureTime) onVerificationSuccess;

  const FaceVerificationStep({
    super.key,
    required this.onVerificationSuccess,
  });

  @override
  State<FaceVerificationStep> createState() => _FaceVerificationStepState();
}

class _FaceVerificationStepState extends State<FaceVerificationStep> with TickerProviderStateMixin {
  final _faceService = FaceRecognitionService();
  final GlobalKey _cameraKey = GlobalKey(); 

  bool _isLoadingVerification = false;
  String _statusMessage = "Posisikan wajah di dalam area";
  Color _statusColor = Colors.white;
  
  // Countdown State
  int _countdown = 3;
  Timer? _timer;
  bool _isCameraReady = false;

  // Animation Controllers
  late AnimationController _breathingController; 
  late AnimationController _scanController;      

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _onCameraReady(bool isReady) {
    if (isReady && mounted) {
      setState(() {
        _isCameraReady = true;
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 1) {
          _countdown--;
          _statusMessage = "Tahan posisi... $_countdown";
        } else {
          _countdown = 0;
          _statusMessage = "Memproses...";
          timer.cancel();
          _triggerCapture();
        }
      });
    });
  }

  void _triggerCapture() {
    final state = _cameraKey.currentState;
    // ignore: invalid_use_of_protected_member
    (state as dynamic).takePicture(); 
  }

  void _onPictureCaptured(XFile? imageFile) {
    if (imageFile != null) {
      _handleVerification(imageFile);
    } else {
      _resetProcess("Gagal mengambil foto.", isError: true);
    }
  }

  Future<void> _handleVerification(XFile imageToVerify) async {
    setState(() => _isLoadingVerification = true);

    try {
      final result = await _faceService.verifyFace(imageToVerify);
      
      if (result.verified) {
        _breathingController.stop(); 
        _scanController.stop();
        widget.onVerificationSuccess(result, DateTime.now());
      } else {
        _resetProcess("Wajah tidak cocok. Coba lagi.", isError: true);
      }
    } catch (e) {
      _resetProcess("Wajah tidak terdeteksi.", isError: true);
    }
  }

  void _resetProcess(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _isLoadingVerification = false;
      _statusMessage = message;
      _statusColor = isError ? AppColors.error : Colors.white;
      _countdown = 3;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
           _statusMessage = "Posisikan wajah di dalam area";
           _statusColor = Colors.white;
        });
        _startCountdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400, 
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                // FIX: Gunakan withValues
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. KAMERA
                CameraWidget(
                  key: _cameraKey,
                  onCameraReady: _onCameraReady,
                  onPictureTaken: _onPictureCaptured,
                ),

                // 2. OVERLAY CANGGIH
                AnimatedBuilder(
                  animation: Listenable.merge([_breathingController, _scanController]),
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TechFaceOverlayPainter(
                        breathingValue: _breathingController.value,
                        scanValue: _scanController.value,
                        isLoading: _isLoadingVerification,
                      ),
                    );
                  },
                ),

                // 3. COUNTDOWN & STATUS
                Positioned(
                  bottom: 30, left: 0, right: 0,
                  child: Column(
                    children: [
                      if (_countdown > 0 && _isCameraReady && !_isLoadingVerification)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            // FIX: Gunakan withValues
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Text(
                            "$_countdown",
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          // FIX: Gunakan withValues
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: _isLoadingVerification
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(color: AppColors.neonGreen, strokeWidth: 2),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Memverifikasi Wajah...",
                                  style: GoogleFonts.hankenGrotesk(color: Colors.white),
                                )
                              ],
                            )
                          : Text(
                              _statusMessage,
                              style: GoogleFonts.hankenGrotesk(
                                color: _statusColor, fontWeight: FontWeight.w600, letterSpacing: 0.5
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TechFaceOverlayPainter extends CustomPainter {
  final double breathingValue;
  final double scanValue;
  final bool isLoading;

  TechFaceOverlayPainter({
    required this.breathingValue,
    required this.scanValue,
    required this.isLoading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // FIX: Gunakan withValues
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.7);
    final backgroundPath = Path()..addRect(rect);

    final scale = 0.98 + (breathingValue * 0.04); 
    
    final ovalW = size.width * 0.65 * scale;
    final ovalH = size.height * 0.50 * scale;
    final ovalLeft = (size.width - ovalW) / 2;
    final ovalTop = (size.height - ovalH) / 2 - 30;
    final faceRect = Rect.fromLTWH(ovalLeft, ovalTop, ovalW, ovalH);

    final facePath = Path()..addOval(faceRect);

    final maskPath = Path.combine(PathOperation.difference, backgroundPath, facePath);
    canvas.drawPath(maskPath, bgPaint);

    final outlinePaint = Paint()
      // FIX: Gunakan withValues
      ..color = isLoading ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    _drawDashedPath(canvas, facePath, outlinePaint);

    final cornerPaint = Paint()
      ..color = isLoading ? AppColors.neonGreen : AppColors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double cornerLen = 30;
    final double gap = 20;

    // Gambar sudut-sudut (Sama seperti sebelumnya)
    canvas.drawLine(Offset(ovalLeft - gap, ovalTop - gap + cornerLen), Offset(ovalLeft - gap, ovalTop - gap), cornerPaint);
    canvas.drawLine(Offset(ovalLeft - gap, ovalTop - gap), Offset(ovalLeft - gap + cornerLen, ovalTop - gap), cornerPaint);
    canvas.drawLine(Offset(faceRect.right + gap - cornerLen, ovalTop - gap), Offset(faceRect.right + gap, ovalTop - gap), cornerPaint);
    canvas.drawLine(Offset(faceRect.right + gap, ovalTop - gap), Offset(faceRect.right + gap, ovalTop - gap + cornerLen), cornerPaint);
    canvas.drawLine(Offset(ovalLeft - gap, faceRect.bottom + gap - cornerLen), Offset(ovalLeft - gap, faceRect.bottom + gap), cornerPaint);
    canvas.drawLine(Offset(ovalLeft - gap, faceRect.bottom + gap), Offset(ovalLeft - gap + cornerLen, faceRect.bottom + gap), cornerPaint);
    canvas.drawLine(Offset(faceRect.right + gap, faceRect.bottom + gap - cornerLen), Offset(faceRect.right + gap, faceRect.bottom + gap), cornerPaint);
    canvas.drawLine(Offset(faceRect.right + gap, faceRect.bottom + gap), Offset(faceRect.right + gap - cornerLen, faceRect.bottom + gap), cornerPaint);

    if (!isLoading) {
      final scanY = ovalTop + (ovalH * scanValue);
      
      final scanPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            // FIX: Gunakan withValues
            AppColors.neonGreen.withValues(alpha: 0),
            AppColors.neonGreen.withValues(alpha: 0.8),
            AppColors.neonGreen.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(ovalLeft, scanY, ovalW, 20));

      canvas.drawRect(Rect.fromLTWH(ovalLeft, scanY, ovalW, 4), scanPaint);
    }
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    // Menggunakan ui.PathMetrics
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    
    // Menggunakan ui.PathMetric
    for (final ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + 10), 
          paint,
        );
        distance += 20; 
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}