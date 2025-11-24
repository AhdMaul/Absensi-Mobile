import 'package:intl/intl.dart';
import '../../../services/api_base.dart';

class AttendanceService {
  final ApiBase _apiBase = ApiBase.instance;

  // Fungsi untuk kirim absen
  Future<Map<String, dynamic>> submitAttendance({
    required double latitude,
    required double longitude,
    String status = 'present',
    required DateTime timestampForLog,
  }) async {
    try {
      // PERBAIKAN: Gunakan '/attendance' saja.
      // Backend route: router.post('/attendance', ...)
      // Asumsi server mount di /api, jadi total: /api/attendance
      const String endpoint = '/attendance'; 

      final Map<String, dynamic> body = {
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
      };

      print(">>> [Flutter] Kirim Absen ke: $endpoint");
      print(">>> [Flutter] Data: $body");
      
      final responseBody = await _apiBase.post(
        endpoint,
        body: body,
        useExpress: true, 
      );

      return responseBody;

    } on ApiException catch (e) {
      // Tangkap pesan dari backend (misal: "Anda sudah absen pulang")
      rethrow; // Teruskan error ini ke Widget agar bisa ditampilkan di SnackBar
    } catch (e) {
      print("Error Tak Terduga: $e");
      throw ApiException("Terjadi kesalahan sistem saat absen.");
    }
  }

  // Fungsi untuk ambil history
  Future<List<dynamic>> getHistory() async {
    try {
      const String endpoint = '/attendance'; 
      
      final response = await _apiBase.get(
        endpoint,
        useExpress: true,
      );

      return response['attendances'] ?? [];
    } catch (e) {
      print("Gagal ambil history: $e");
      return [];
    }
  }
}