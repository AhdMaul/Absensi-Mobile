import 'package:intl/intl.dart';
import '../../../services/api_base.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final ApiBase _apiBase = ApiBase.instance;

  // --- 1. Submit Absensi (Sesuai AbsensiWidget) ---
  // Backend tidak butuh userId/timestamp di body request
  Future<Map<String, dynamic>> submitAttendance({
    required double latitude,
    required double longitude,
    String status = 'present',
    required DateTime timestampForLog,
  }) async {
    try {
      // Endpoint: /attendance (karena di router backend: post('/', ...))
      const String endpoint = '/attendance'; 

      final Map<String, dynamic> body = {
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
      };

      // Gunakan debugPrint atau log jika ada
      // print(">>> [Flutter] Kirim Absen ke: $endpoint"); 

      final responseBody = await _apiBase.post(
        endpoint,
        body: body,
        useExpress: true,
      );

      return responseBody;

    } on ApiException {
      rethrow; // Biarkan error API naik ke UI
    } catch (e) {
      throw 'Terjadi kesalahan sistem saat absen.';
    }
  }

  // --- 2. Ambil Riwayat (Sesuai HomeController) ---
  // Menggunakan endpoint GET /attendance yang mengembalikan data hari ini (atau semua, tergantung backend)
  Future<List<dynamic>> getHistory() async {
    try {
      const String endpoint = '/attendance'; 
      
      final response = await _apiBase.get(
        endpoint,
        useExpress: true,
      );

      // Backend return: { success: true, attendances: [...] }
      return response['attendances'] ?? [];
    } catch (e) {
      // print("Gagal ambil history: $e");
      return [];
    }
  }

  // (Optional) Fungsi lama fetchUserAttendances bisa dihapus atau disesuaikan
  Future<List<AttendanceModel>> fetchUserAttendances(int userId) async {
     // ... (bisa dihapus jika tidak dipakai lagi)
     return [];
  }
}