// lib/features/home/services/permission_service.dart

import 'dart:io';
import 'package:intl/intl.dart';
import '../../../services/api_base.dart';

class PermissionService {
  final String _endpoint = "/permissions";

  Future<bool> submitPermission({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    File? attachment,
  }) async {
    try {
      String dateToSend = startDate.toIso8601String();

      String formattedEnd = DateFormat('dd MMM yyyy').format(endDate);
      String combinedReason = "$reason (Sampai tgl: $formattedEnd)";

      final Map<String, String> fields = {
        'type': type,
        'date': dateToSend, 
        'reason': combinedReason,
      };

      // 4. Siapkan List File
      List<String> files = [];
      if (attachment != null) {
        files.add(attachment.path);
      }

      // 5. Kirim Request
      await ApiBase.instance.postMultipart(
        _endpoint,
        fields: fields,
        filePaths: files,
        fileField: 'attachment', 
        useExpress: true,
      );

      return true;
    } catch (e) {
      print("Error submitPermission: $e");
      rethrow;
    }
  }
}
