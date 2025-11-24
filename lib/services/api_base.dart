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
  // Pastikan IP sesuai
  static const String _baseUrlExpress = "http://192.168.1.66:5000/api";
  static const String _baseUrlFastAPI = "http://192.168.1.66:8000/api";
  static const Duration _timeoutDuration = Duration(seconds: 15); 

  ApiBase._privateConstructor();
  static final ApiBase _instance = ApiBase._privateConstructor();
  static ApiBase get instance => _instance;

  // --- Helper Headers ---
  Future<Map<String, String>> _getHeaders({bool isJson = true, bool useToken = true}) async {
    final headers = <String, String>{};
    if (isJson) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=UTF-8';
    }
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
      // RETHROW jika sudah ApiException, lempar error lain jika bukan
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
     final headers = await _getHeaders(isJson: false); 
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

   Future<Map<String, dynamic>> postMultipart(String endpoint, {required List<String> filePaths, Map<String, String>? fields, bool useExpress = false}) async {
       final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
       final url = Uri.parse('$baseUrl$endpoint');
       final headers = await _getHeaders(isJson: false);

       var request = http.MultipartRequest('POST', url);
       request.headers.addAll(headers); 

       if (fields != null) {
           request.fields.addAll(fields);
       }

       for (String filePath in filePaths) {
           request.files.add(await http.MultipartFile.fromPath('images', filePath));
       }

       try {
           final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
           final response = await http.Response.fromStream(streamedResponse);
           return _processResponse(response);
       } on SocketException {
           throw ApiException('Koneksi internet terputus. Cek wifi/data kamu.');
       } catch (e) {
           if (e is ApiException) rethrow;
           throw ApiException('Gagal mengupload data: $e');
       }
   }


  // --- RESPONSE HANDLER DIPERBAIKI ---
  Map<String, dynamic> _processResponse(http.Response response) {
    print("<<< Response [${response.statusCode}]");
    
    // Decode JSON
    Map<String, dynamic> responseBody = {};
    try {
      if (response.body.isNotEmpty) {
        responseBody = jsonDecode(response.body);
      }
    } catch (e) {
      // Jika response bukan JSON (misal HTML error page)
      throw ApiException("Terjadi kesalahan server (Format Data Salah).", statusCode: response.statusCode);
    }

    // Handle Status Code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } 
    else if (response.statusCode == 401) {
      throw ApiException('Sesi berakhir. Silakan login ulang.', statusCode: response.statusCode);
    } 
    else {
      // --- PERBAIKAN DI SINI ---
      // Langsung ambil pesan dari backend TANPA tambahan teks "Ada kendala..."
      // Backend kamu mengirim: { "success": false, "message": "..." }
      final errorMessage = responseBody['message'] ?? 'Terjadi kesalahan pada server.';
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}