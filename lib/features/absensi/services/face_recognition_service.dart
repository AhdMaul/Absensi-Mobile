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

      // PERBAIKAN: Tembak LANGSUNG ke FastAPI
      // Gunakan method khusus postUrlEncodedFastAPI (jika ada di ApiBase)
      // Atau post biasa dengan useExpress: false
      
      final responseBody = await _apiBase.postUrlEncodedFastAPI( // Pastikan method ini ada di ApiBase
        '/recognize', 
        body: {
          'image_base64': imageBase64, // FastAPI butuh key ini
        },
        // Tidak perlu useExpress: true karena ini ke FastAPI
      );

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