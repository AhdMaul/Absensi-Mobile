import 'dart:convert'; 
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Untuk token

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return "ApiException: $message ${statusCode != null ? '(Status code: $statusCode)' : ''}";
  }
}

class ApiBase {
  // --- Base URLs ---
  static const String _baseUrlExpress = "http://192.168.1.90:5000/api";
  static const String _baseUrlFastAPI = "http://192.168.1.90:8000/api";

  // --- Timeout ---
  static const Duration _timeoutDuration = Duration(seconds: 15); // Timeout default 15 detik

  ApiBase._privateConstructor();
  static final ApiBase _instance = ApiBase._privateConstructor();
  static ApiBase get instance => _instance;

  // --- Helper untuk Mendapatkan Headers ---
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

  // --- Helper Methods ---

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {bool useExpress = true}) async {
    final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    print(">>> GET Request => URL: $url");
    print(">>> Headers: $headers");

    try {
      final response = await http.get(url, headers: headers).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
       throw ApiException('Tidak ada koneksi internet.');
    } catch (e) {
      print("!!! GET Error: $e");
      throw ApiException('Terjadi kesalahan saat memproses permintaan.');
    }
  }

  // POST request (biasanya JSON)
  Future<Map<String, dynamic>> post(String endpoint, {required Map<String, dynamic> body, bool useExpress = true}) async {
    final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(); // Defaultnya isJson=true
    final encodedBody = jsonEncode(body);

    print(">>> POST Request => URL: $url");
    print(">>> Headers: $headers");
    print(">>> Body: $encodedBody");

    try {
      final response = await http.post(url, headers: headers, body: encodedBody).timeout(_timeoutDuration);
      return _processResponse(response);
    } on SocketException {
       throw ApiException('Tidak ada koneksi internet.');
    } catch (e) {
      print("!!! POST Error: $e");
      throw ApiException('Terjadi kesalahan saat memproses permintaan.');
    }
  }

   // POST request (untuk FastAPI yang pakai x-www-form-urlencoded)
   // Contoh spesifik untuk verify face yang butuh format ini
   Future<Map<String, dynamic>> postUrlEncodedFastAPI(String endpoint, {required Map<String, String> body}) async {
     final baseUrl = _baseUrlFastAPI;
     final url = Uri.parse('$baseUrl$endpoint');
     // Headers sedikit berbeda, isJson=false
     final headers = await _getHeaders(isJson: false);
     // Untuk x-www-form-urlencoded, 'body' bisa langsung Map<String, String>

     print(">>> POST (Form Encoded) Request => URL: $url");
     print(">>> Headers: $headers");
     print(">>> Body: $body");

     try {
       final response = await http.post(url, headers: headers, body: body).timeout(_timeoutDuration);
       return _processResponse(response);
     } on SocketException {
        throw ApiException('Tidak ada koneksi internet.');
     } catch (e) {
       print("!!! POST (Form Encoded) Error: $e");
       throw ApiException('Terjadi kesalahan saat memproses permintaan.');
     }
   }

   // POST request multipart (untuk upload file/gambar)
   Future<Map<String, dynamic>> postMultipart(String endpoint, {required List<String> filePaths, Map<String, String>? fields, bool useExpress = false}) async {
       final baseUrl = useExpress ? _baseUrlExpress : _baseUrlFastAPI;
       final url = Uri.parse('$baseUrl$endpoint');
       final headers = await _getHeaders(isJson: false); // isJson = false untuk multipart

       print(">>> POST (Multipart) Request => URL: $url");
       print(">>> Headers (without Content-Type): $headers");
       print(">>> File Paths: $filePaths");
       print(">>> Fields: $fields");


       var request = http.MultipartRequest('POST', url);
       request.headers.addAll(headers); // Tambahkan header (termasuk token jika ada)

       // Tambahkan fields (jika ada)
       if (fields != null) {
           request.fields.addAll(fields);
       }

       // Tambahkan files
       for (String filePath in filePaths) {
         // 'images' adalah key yg diharapkan backend FastAPI
           request.files.add(await http.MultipartFile.fromPath('images', filePath));
       }

       try {
           final streamedResponse = await request.send().timeout(const Duration(seconds: 60)); // Timeout lebih lama untuk upload
           final response = await http.Response.fromStream(streamedResponse);
           return _processResponse(response);
       } on SocketException {
           throw ApiException('Tidak ada koneksi internet.');
       } catch (e) {
           print("!!! POST (Multipart) Error: $e");
           throw ApiException('Terjadi kesalahan saat mengunggah file.');
       }
   }


  // --- Helper untuk Memproses Response ---
  Map<String, dynamic> _processResponse(http.Response response) {
    print("<<< Response [${response.statusCode}]");
    print("<<< Body: ${response.body}");

    final Map<String, dynamic> responseBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses
      return responseBody;
    } else if (response.statusCode == 401) {
      // Unauthorized -> mungkin token expired
      // TODO: Handle logout atau refresh token jika ada
      print("!!! Unauthorized (401). Token mungkin expired.");
      // Bisa panggil fungsi logout global di sini
      throw ApiException(responseBody['message'] ?? 'Sesi berakhir, silahkan login kembali.', statusCode: response.statusCode);
    } else {
      // Error lainnya dari server
      throw ApiException(responseBody['message'] ?? 'Terjadi kesalahan dari server.', statusCode: response.statusCode);
    }
  }
}

// Cara Penggunaan di Service Fitur (contoh AuthService):
/*
import 'dart:convert';
import '../services/api_base.dart';

class AuthService {
  final ApiBase _apiBase = ApiBase.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final responseBody = await _apiBase.post('/auth/login', body: {
        'email': email,
        'password': password,
      }, useExpress: true); // Pastikan useExpress = true
      return responseBody;
    } on ApiException catch (e) {
      // Tangani error spesifik API (misal tampilkan e.message ke user)
      print("Login failed: ${e.message}");
      rethrow; // Lempar lagi agar bisa ditangani di UI
    } catch (e) {
      // Tangani error general lain
      print("An unexpected error occurred: $e");
      throw 'Terjadi kesalahan tidak terduga.';
    }
  }

  // Contoh panggil FastAPI verify
  Future<Map<String, dynamic>> verifyFace(String imageBase64) async {
     try {
       // Sesuai contoh frontend,
       // endpoint recognize pakai x-www-form-urlencoded
       final responseBody = await _apiBase.postUrlEncodedFastAPI('/recognize', body: {
         'image_base64': imageBase64,
       });
       return responseBody;
     } on ApiException catch (e) {
       print("Verify face failed: ${e.message}");
       rethrow;
     } catch (e) {
       print("An unexpected error occurred during face verify: $e");
       throw 'Terjadi kesalahan tidak terduga.';
     }
  }

  // Contoh panggil FastAPI register face (upload gambar)
  Future<Map<String, dynamic>> registerFace(List<String> imageFilePaths) async {
      try {
          final responseBody = await _apiBase.postMultipart(
              '/register', // Endpoint FastAPI untuk register face
              filePaths: imageFilePaths,
              useExpress: false // Pakai baseUrl FastAPI
          );
          return responseBody;
      } on ApiException catch (e) {
          print("Register face failed: ${e.message}");
          rethrow;
      } catch (e) {
          print("An unexpected error occurred during face register: $e");
          throw 'Terjadi kesalahan tidak terduga.';
      }
  }
}

*/