import 'dart:io';
import '../../../services/api_base.dart'; // Import ApiBase

class PermissionService {
  // Endpoint API (sesuai route di backend: /api/permissions)
  final String _endpoint = "/permissions"; 

  Future<bool> submitPermission({
    required String type, // 'sick' atau 'permit'
    required DateTime date,
    required String reason,
    File? attachment,
  }) async {
    try {
      // 1. Siapkan Data Fields
      final Map<String, String> fields = {
        'type': type,
        'date': date.toIso8601String(),
        'reason': reason,
      };

      // 2. Siapkan File (Jika ada)
      List<String> files = [];
      if (type == 'sick' && attachment != null) {
        files.add(attachment.path);
      }

      // 3. Panggil ApiBase
      // Kita gunakan postMultipart untuk keduanya (Izin & Sakit).
      // Jika Izin, list 'files' kosong, request tetap valid sebagai Multipart.
      final response = await ApiBase.instance.postMultipart(
        _endpoint,
        fields: fields,
        filePaths: files,
        fileField: 'attachment', // Sesuai requirement backend
        useExpress: true,        // Backend Permission ada di Express
      );

      // 4. Cek Response
      // ApiBase otomatis melempar error jika status != 200/201,
      // jadi jika sampai sini berarti sukses.
      return true;

    } catch (e) {
      print("Error submitPermission: $e");
      rethrow; // Lempar error ke UI (Modal) untuk ditampilkan di Snackbar
    }
  }
}