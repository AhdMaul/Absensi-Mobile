import 'dart:convert';
import 'package:camera/camera.dart';
import '../../../services/api_base.dart';
import '../models/verification_result_model.dart';

class FaceRecognitionService {
  final ApiBase _apiBase = ApiBase.instance;

  Future<VerificationResultModel> verifyFace(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      print('Sending face verify request, image bytes: ${imageBytes.length}');

      // Kirim sebagai Form URL Encoded sesuai kebutuhan endpoint FastAPI
      final responseBody = await _apiBase.postUrlEncodedFastAPI(
        '/recognize',
        body: {
          'image_base64': imageBase64,
        },
      );

      // --- LOG DEBUGGING TAMBAHAN ---
      // Lihat output ini di Debug Console untuk mengetahui struktur JSON asli
      print(">>> RAW RESPONSE DARI SERVER: $responseBody");
      // ------------------------------

      return VerificationResultModel.fromJson(responseBody);

    } on ApiException catch (e) {
      print("Face Verify Error: ${e.message}");
      return VerificationResultModel(verified: false, message: e.message);
    } catch (e) {
      print("System Error: $e");
      return VerificationResultModel(verified: false, message: 'Gagal memproses wajah.');
    }
  }
}