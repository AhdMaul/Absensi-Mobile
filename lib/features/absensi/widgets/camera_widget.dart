// lib/features/face_recognition/widgets/camera_widget.dart
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  final Function(XFile? imageFile)? onPictureTaken;
  final Function(bool isReady)? onCameraReady; // Callback saat kamera siap

  const CameraWidget({
    this.onPictureTaken,
    this.onCameraReady,
    super.key,
  });

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Cari kamera depan
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.high, // Gunakan High agar tajam
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
        // Beritahu parent bahwa kamera siap untuk memulai countdown
        widget.onCameraReady?.call(true);
      }
    } catch (e) {
      debugPrint("Error camera: $e");
    }
  }

  // Fungsi publik untuk dipanggil parent
  Future<void> takePicture() async {
    if (!_isCameraInitialized || controller == null) return;
    if (controller!.value.isTakingPicture) return;

    try {
      final image = await controller!.takePicture();
      widget.onPictureTaken?.call(image);
    } catch (e) {
      debugPrint("Error capturing: $e");
      widget.onPictureTaken?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // --- LOGIKA ANTI-GEPENG (COVER) ---
    return LayoutBuilder(
      builder: (context, constraints) {
        var scale = 1.0;
        
        // Hitung aspect ratio kamera vs layar
        // Kamera biasanya landscape (4:3 atau 16:9), tapi di HP tampil portrait.
        // Kita perlu menukar width/height kamera untuk perbandingan.
        final cameraAspectRatio = controller!.value.aspectRatio;
        final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

        // Karena kamera depan biasanya mirrored dan orientasinya beda,
        // logika scale ini memastikan gambar mengisi penuh kotak (cover)
        // tanpa terdistorsi.
        scale = 1 / (cameraAspectRatio * screenAspectRatio); 
        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(
              child: CameraPreview(controller!),
            ),
          ),
        );
      },
    );
  }
}