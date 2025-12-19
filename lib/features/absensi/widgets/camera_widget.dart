// lib/features/face_recognition/widgets/camera_widget.dart
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  final Function(XFile? imageFile)? onPictureTaken;
  final Function(bool isReady)? onCameraReady;

  const CameraWidget({this.onPictureTaken, this.onCameraReady, super.key});

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

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        frontCamera,

        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
        widget.onCameraReady?.call(true);
      }
    } catch (e) {
      debugPrint("Error camera: $e");
    }
  }

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
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var scale = 1.0;
        final cameraAspectRatio = controller!.value.aspectRatio;
        final screenAspectRatio = constraints.maxWidth / constraints.maxHeight;

        scale = 1 / (cameraAspectRatio * screenAspectRatio);
        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: Center(child: CameraPreview(controller!)),
          ),
        );
      },
    );
  }
}
