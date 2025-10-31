import 'package:shared_preferences/shared_preferences.dart'; 
import '../../../services/api_base.dart'; 
import '../models/login_response_models.dart'; 

class AuthService {
  final ApiBase _apiBase = ApiBase.instance; 

  Future<LoginResponseModel> login(String email, String password) async {
    try {
      final responseBody = await _apiBase.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
        useExpress: true, 
      );

      final loginResponse = LoginResponseModel.fromJson(responseBody);

      if (loginResponse.success && loginResponse.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', loginResponse.token!);
        print("Token saved successfully!");
      }

      return loginResponse;

    } on ApiException catch (e) {
      print("Login failed (ApiException): ${e.message}");
      return LoginResponseModel(success: false, message: e.message);
    } catch (e) {
      print("An unexpected error occurred during login: $e");
      return LoginResponseModel(success: false, message: 'Terjadi kesalahan tidak terduga.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 
    print("Token removed successfully!");
  }


  Future<bool> isLoggedIn() async {
     final prefs = await SharedPreferences.getInstance();
     final token = prefs.getString('token');
     return token != null && token.isNotEmpty;
  }


}