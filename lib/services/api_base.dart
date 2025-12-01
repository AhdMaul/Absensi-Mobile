import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return message;
  }
}

class ApiBase {
  // URL Backend (Pastikan URL ini benar dan bisa diakses)
  static const String _baseUrlExpress = "https://my-backend-5rrp.onrender.com/api";
  static const String _baseUrlFastAPI = "https://eshrm.onrender.com/api";

  // Timeout dinaikkan ke 60 detik untuk mengakomodasi proses upload/AI yang lama
  static const Duration _timeoutDuration = Duration(seconds: 60);

  ApiBase._privateConstructor();
  static final ApiBase _instance = ApiBase._privateConstructor();
  static ApiBase get instance => _instance;

  Future<Map<String, String>> _getHeaders({bool isJson = true, bool useToken = true}) async {
    final headers = <String, String>{};
    if (isJson) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=UTF-8';
    }
    // Header accept ini standar, biasanya aman
    headers[HttpHeaders.acceptHeader] = 'application/json';

    if (useToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- METHODS ---

  Future<Map<String, dynamic>> get(String endpoint, {bool useExpress = true}) async {
    final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    print(">>> GET Request => URL: $url");

    try {
      final response = await http.get(url, headers: headers).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Koneksi internet terputus. Cek wifi/data kamu.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {required Map<String, dynamic> body, bool useExpress = true}) async {
    final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final encodedBody = jsonEncode(body);

    print(">>> POST Request => URL: $url");

    try {
      final response = await http.post(url, headers: headers, body: encodedBody).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Koneksi internet terputus. Cek wifi/data kamu.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  Future<Map<String, dynamic>> postUrlEncodedFastAPI(String endpoint, {required Map<String, String> body}) async {
    final baseUrl = _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');

    // Ambil header dasar (Auth token dll), tapi set isJson false
    final headers = await _getHeaders(isJson: false);

    // Set Content-Type manual untuk Form UrlEncoded
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    print(">>> POST (Form Encoded) Request => URL: $url");

    try {
      final response = await http.post(url, headers: headers, body: body).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Koneksi internet terputus. Cek wifi/data kamu.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal menghubungi server: $e');
    }
  }

  // --- METHOD MULTIPART (DIPERBARUI) ---
  // Parameter 'fileField' memungkinkan kita mengganti nama field file (default: 'images')
  // Ini penting untuk fitur Izin yang menggunakan field 'attachment'
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required List<String> filePaths,
    Map<String, String>? fields,
    String fileField = 'images', // Default 'images' (untuk Face Rec), ganti jadi 'attachment' utk Izin
    bool useExpress = false,
  }) async {
    final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(isJson: false);

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Loop file dan gunakan nama field yang dinamis sesuai parameter
    for (String filePath in filePaths) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    print(">>> POST MULTIPART Request => URL: $url | Field: $fileField | Files: ${filePaths.length}");

    try {
      // Timeout lebih lama untuk upload file
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90)); 
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Koneksi internet terputus. Cek wifi/data kamu.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Gagal mengupload data: $e');
    }
  }

  // --- RESPONSE HANDLER ---
  Map<String, dynamic> _processResponse(http.Response response) {
    print("<<< Response [${response.statusCode}]");

    Map<String, dynamic> responseBody = {};
    try {
      if (response.body.isNotEmpty) {
        responseBody = jsonDecode(response.body);
      }
    } catch (e) {
      // Menangani kasus jika server error mengembalikan HTML (bukan JSON)
      if (response.statusCode == 500) {
        throw ApiException("Server Error (Internal). Coba lagi nanti.", statusCode: 500);
      }
      // Jika bukan 500 tapi format salah
      throw ApiException("Format respon server tidak valid.", statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else if (response.statusCode == 401) {
      throw ApiException('Sesi berakhir. Silakan login ulang.', statusCode: response.statusCode);
    } else {
      final errorMessage = responseBody['message'] ?? 'Terjadi kesalahan pada server.';
      // Log detail error dari backend jika ada (misal validasi error)
      if (responseBody.containsKey('detail')) {
        print("API Detail Error: ${responseBody['detail']}");
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}