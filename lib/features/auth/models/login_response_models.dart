class UserModel {
  final String id;
  final String email;
  final String password;

  UserModel({required this.id, required this.email, required this.password});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}


class LoginResponseModel {
  final bool success;
  final String message;
  final String? token; 
  final UserModel? user;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      token: json['token'], 
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }
}