import '../../../services/api_base.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final ApiBase _apiBase = ApiBase.instance;

  Future<Map<String, dynamic>> submitAttendance(AttendanceModel data) async {
    try {
      final response = await _apiBase.post(
        '/attendance', 
        body: data.toJson(),
        useExpress: true,
      );
      return response;
    } on ApiException catch (e) {
      print("Submit attendance failed: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error on submitAttendance: $e");
      throw 'Terjadi kesalahan tidak terduga.';
    }
  }

  Future<List<AttendanceModel>> fetchUserAttendances(int userId) async {
    try {
      final res = await _apiBase.get('/attendance/$userId');
      final List data = res['data'] ?? [];
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } on ApiException catch (e) {
      print("Fetch attendance failed: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error on fetchUserAttendances: $e");
      throw 'Terjadi kesalahan saat mengambil data absensi.';
    }
  }
}
