// lib/features/auth/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_base.dart';
import '../models/login_response_models.dart';

class AuthService {
  final ApiBase _apiBase = ApiBase.instance;

  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final responseBody = await _apiBase.post(
        '/auth/login',
        body: {'email': email, 'password': password},
        useExpress: true,
      );

      final loginResponse = LoginResponseModel.fromJson(responseBody);

      if (loginResponse.success && loginResponse.token != null) {
        final prefs = await SharedPreferences.getInstance();

        // --- SIMPAN TOKEN & DATA USER ---
        await prefs.setString('token', loginResponse.token!);

        if (loginResponse.user != null) {
          await prefs.setString('userId', loginResponse.user!.id);
          await prefs.setString('userName', loginResponse.user!.name);
          await prefs.setString('userEmail', loginResponse.user!.email);
        }

        print("Token and user data saved successfully!");
      }

      return loginResponse;
    } on ApiException catch (e) {
      print("Login failed (ApiException): ${e.message}");
      return LoginResponseModel(success: false, message: e.message);
    } catch (e) {
      print("An unexpected error occurred during login: $e");
      return LoginResponseModel(
        success: false,
        message: 'Terjadi kesalahan tidak terduga.',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus semua data sesi
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    print("All user session data removed!");
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
