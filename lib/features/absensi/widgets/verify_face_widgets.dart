import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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

class _FaceVerificationStepState extends State<FaceVerificationStep> {
  final _faceService = FaceRecognitionService();
  bool _isLoadingVerification = false;
  VerificationResultModel? _verificationResult;
  String _verificationMessage = '';
  String _errorMessage = '';
  XFile? _lastCapturedImage;

  Timer? _retryTimer;

  @override
  void dispose() {
    _cancelRetryTimer();
    super.dispose();
  }

  void _onPictureCaptured(XFile? imageFile) {
    _cancelRetryTimer();
    if (imageFile != null) {
      setState(() {
        _lastCapturedImage = imageFile;
        _verificationResult = null;
        _verificationMessage = '';
        _errorMessage = '';
      });
      _handleVerification(imageFile);
    } else {
      if (!mounted) return;
      setState(() { _errorMessage = "Gagal mengambil gambar. Coba lagi."; });
    }
  }

  Future<void> _handleVerification(XFile imageToVerify, {bool isRetry = false}) async {
    if (!mounted) return;
    setState(() { _isLoadingVerification = true; });

    if (!isRetry) _cancelRetryTimer();

    try {
      final result = await _faceService.verifyFace(imageToVerify);
      if (!mounted) return;

      String message;
      Color snackbarColor;

      if (result.verified) {
        DateTime successTime = DateTime.now();
        message = "✅ Wajah Terverifikasi!";
        snackbarColor = Colors.green;
        _cancelRetryTimer();
        widget.onVerificationSuccess(result, successTime);

      } else {
        message = "⚠️ Wajah tidak dikenali. ${result.message}";
        snackbarColor = Colors.orange;
        _startRetryTimer(imageToVerify); 
      }

      setState(() {
        _isLoadingVerification = false;
        _verificationResult = result;
        _verificationMessage = message; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: snackbarColor),
      );

    } catch (e) { // Error sistem
      if (!mounted) return;
      final errorMsg = "Terjadi kesalahan sistem: ${e.toString()}";
      setState(() {
        _isLoadingVerification = false;
        _errorMessage = errorMsg;
        _verificationMessage = "❌ Error Verifikasi Wajah.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      _startRetryTimer(imageToVerify);
    }
  }

  void _startRetryTimer(XFile imageToRetry) {
     _cancelRetryTimer();
     const retryDuration = Duration(seconds: 5);
     print("Verifikasi gagal, mencoba lagi dalam ${retryDuration.inSeconds} detik...");
     _retryTimer = Timer(retryDuration, () {
        if (!mounted) return;
        print("Mencoba verifikasi ulang otomatis...");
        _handleVerification(imageToRetry, isRetry: true);
     });
     if(mounted) setState(() {});
  }

  void _cancelRetryTimer() {
     if (_retryTimer?.isActive ?? false) {
        print("Membatalkan timer auto-retry.");
        _retryTimer!.cancel();
     }
     _retryTimer = null;
     if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah 2: Verifikasi Wajah',
           style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Posisikan wajah Anda pada kamera lalu tekan tombol ambil foto.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        CameraWidget(
          initialMode: CameraCaptureMode.photo,
          onPictureTaken: _onPictureCaptured,
          initialCameraType: CameraType.back, // Default ke kamera belakang
        ),
        const SizedBox(height: 50),

        if (_isLoadingVerification)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: CircularProgressIndicator(),
          )
        )

        else if (_verificationMessage.isNotEmpty)
           Card(
            color: (_verificationResult?.verified ?? false) ? Colors.green.shade50 : Colors.orange.shade50,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    (_verificationResult?.verified ?? false) ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: (_verificationResult?.verified ?? false) ? Colors.green : Colors.orange,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _verificationMessage, 
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (_verificationResult?.verified ?? false) ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!(_verificationResult?.verified ?? true) && _lastCapturedImage != null)
                     Padding(
                       padding: const EdgeInsets.only(top: 16.0),
                       child: OutlinedButton(
                          onPressed: _isLoadingVerification ? null : () => _handleVerification(_lastCapturedImage!),
                          child: const Text('Coba Verifikasi Ulang Wajah'),
                       ),
                     ),
                  if (_retryTimer?.isActive ?? false)
                    Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                          'Mencoba lagi dalam beberapa detik...',
                          style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                       ),
                    ),
                ],
              ),
            ),
           )
        else if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
      ],
    );
  }
}