import 'dart:convert'; // Untuk base64Encode
import 'package:camera/camera.dart'; 
// import 'package:dio/dio.dart'; // Impor jika ApiBase pakai Dio untuk FormData
import '../../../services/api_base.dart'; 
import '../models/verification_result_model.dart'; 

class FaceRecognitionService {
  final ApiBase _apiBase = ApiBase.instance;

  Future<VerificationResultModel> verifyFace(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      final responseBody = await _apiBase.postUrlEncodedFastAPI(
        '/recognize', 
        body: {
          'image_base64': imageBase64, // Key sesuai web
        },
      );

      return VerificationResultModel.fromJson(responseBody);

    } on ApiException catch (e) {
      print("Face Verify failed (ApiException): ${e.message}");
      return VerificationResultModel(verified: false, message: e.message);
    } catch (e) {
      print("An unexpected error occurred during face verify: $e");
      return VerificationResultModel(verified: false, message: 'Terjadi kesalahan tidak terduga.');
    }
  }

  Future<RegistrationResultModel> registerFace(List<XFile> imageFiles) async {
    if (imageFiles.isEmpty) {
       throw ApiException('Tidak ada gambar yang dipilih untuk registrasi wajah.');
    }
    try {
      final imagePaths = imageFiles.map((file) => file.path).toList();

      final responseBody = await _apiBase.postMultipart(
        '/register', 
        filePaths: imagePaths, 
        useExpress: false, 
      );
       return RegistrationResultModel.fromJson(responseBody);
    } on ApiException catch (e) {
      print("Register face failed (ApiException): ${e.message}");
      rethrow;
    } catch (e) {
      print("An unexpected error occurred during face register: $e");
      throw 'Terjadi kesalahan tidak terduga saat registrasi wajah.';
    }
  }

  Future<VerificationResultModel> verifyFaceWithBlinkVideo(XFile videoFile) async {
    try {
      final videoPath = videoFile.path;

      final responseBody = await _apiBase.postMultipart(
          '/verify-blink', 
          filePaths: [videoPath], 
          fields: {},
          useExpress: false
      );
      return VerificationResultModel.fromJson(responseBody);

    } on ApiException catch (e) {
      print("Face Verify Blink failed (ApiException): ${e.message}");
      return VerificationResultModel(verified: false, message: e.message);
    } catch (e) {
      print("An unexpected error occurred during face verify blink: $e");
      return VerificationResultModel(verified: false, message: 'Terjadi kesalahan tidak terduga.');
    }
  }
}