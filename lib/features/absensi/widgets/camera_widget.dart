// lib/features/face_recognition/widgets/camera_widget.dart
import 'dart:async'; // Untuk Timer
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum CameraCaptureMode { photo, video }

class CameraWidget extends StatefulWidget {
  final Function(XFile? imageFile)? onPictureTaken;
  final Function(XFile? videoFile)? onVideoRecorded;
  final CameraCaptureMode initialMode;
  final int videoDurationSeconds;

  const CameraWidget({
    this.onPictureTaken,
    this.onVideoRecorded,
    this.initialMode = CameraCaptureMode.photo,
    this.videoDurationSeconds = 3, 
    super.key,
  });

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription>? cameras;
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isRecordingVideo = false;
  Timer? _videoTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialMode == CameraCaptureMode.photo && widget.onPictureTaken == null) {
      throw ArgumentError('onPictureTaken callback must be provided for photo mode');
    }
    if (widget.initialMode == CameraCaptureMode.video && widget.onVideoRecorded == null) {
       throw ArgumentError('onVideoRecorded callback must be provided for video mode');
    }
    _initializeCamera();
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        print("Kamera tidak ditemukan!");
        if (mounted) setState(() {});
        return;
      }

      CameraDescription selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;
      setState(() { _isCameraInitialized = true; });

      if (widget.initialMode == CameraCaptureMode.video) {
        _startVideoRecording();
      }

    } catch (e) {
      print("Error inisialisasi kamera: $e");
       if (mounted) setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || controller == null || _isTakingPicture || _isRecordingVideo) {
      return;
    }
    setState(() { _isTakingPicture = true; });

    try {
      XFile picture = await controller!.takePicture();
      widget.onPictureTaken!(picture);
    } catch (e) {
      print("Error mengambil gambar: $e");
      widget.onPictureTaken!(null);
    } finally {
       if (mounted) setState(() { _isTakingPicture = false; });
    }
  }

  Future<void> _startVideoRecording() async {
     if (!_isCameraInitialized || controller == null || _isRecordingVideo || _isTakingPicture) {
       return;
     }
     try {
       await controller!.startVideoRecording();
       setState(() { _isRecordingVideo = true; });
       print("Mulai merekam video...");

       _videoTimer = Timer(Duration(seconds: widget.videoDurationSeconds), () {
          print("Waktu rekam habis, menghentikan video...");
          _stopVideoRecording();
       });

     } catch (e) {
       print("Error memulai rekam video: $e");
       if (mounted) setState(() { _isRecordingVideo = false; });
     }
  }

   Future<void> _stopVideoRecording() async {
     if (!_isRecordingVideo || controller == null || !controller!.value.isRecordingVideo) {
       return;
     }
     _videoTimer?.cancel();

     try {
       XFile video = await controller!.stopVideoRecording();
       print("Video berhenti direkam: ${video.path}");
       widget.onVideoRecorded!(video);
     } catch (e) {
       print("Error menghentikan rekam video: $e");
       widget.onVideoRecorded!(null);
     } finally {
        if (mounted) setState(() { _isRecordingVideo = false; });
     }
   }


  @override
  Widget build(BuildContext context) {
    if (controller == null) {
       return const Center(child: Text("Kamera tidak tersedia"));
    }
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: CameraPreview(controller!),
        ),
        const SizedBox(height: 16),

        if (widget.initialMode == CameraCaptureMode.photo)
          ElevatedButton.icon(
            onPressed: _isTakingPicture ? null : _takePicture,
            icon: _isTakingPicture
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.camera_alt),
            label: Text(_isTakingPicture ? "Memproses..." : "Ambil Foto Wajah"),
          )
        else if (widget.initialMode == CameraCaptureMode.video)
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 20.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                  Icon(Icons.videocam, color: _isRecordingVideo ? Colors.red : Colors.grey),
                  const SizedBox(width: 8),
                  Text(_isRecordingVideo ? "Sedang Merekam..." : "Menyiapkan Kamera..."),
               ],
             ),
           )
      ],
    );
  }
}