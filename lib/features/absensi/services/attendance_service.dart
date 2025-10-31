import '../../../services/api_base.dart'; 
import 'package:intl/intl.dart'; 

class AttendanceService {
  final ApiBase _apiBase = ApiBase.instance;
  Future<Map<String, dynamic>> submitAttendance({
    required double latitude,
    required double longitude,
    String status = 'masuk',
    required DateTime timestampForLog,
  }) async {
    const String endpoint = '/attendance';

    final Map<String, dynamic> body = {
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    };
    print(">>> Mengirim data absensi ke Express: $endpoint");
    print(">>> Body: $body");
    print(">>> Waktu Absen (Flutter): ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestampForLog)}");


    try {
      final responseBody = await _apiBase.post(
        endpoint,
        body: body,
        useExpress: true,
      );

      print("<<< Respon simpan absensi: $responseBody");
      return responseBody;

    } on ApiException catch (e) {
      print("Submit Attendance failed (ApiException): ${e.message}");
      throw ApiException(
          'Gagal menyimpan absensi: ${e.message}',
          statusCode: e.statusCode);
    } catch (e) {
      print("An unexpected error occurred during submit attendance: $e");
      throw 'Terjadi kesalahan tidak terduga saat mengirim data absensi.';
    }
  }
}