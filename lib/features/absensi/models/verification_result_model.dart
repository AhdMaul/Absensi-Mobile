class VerificationResultModel {
  final bool verified;
  final String message;

  VerificationResultModel({
    required this.verified,
    required this.message,
  });

  factory VerificationResultModel.fromJson(Map<String, dynamic> json) {
    return VerificationResultModel(
      // Cek berbagai kemungkinan key agar lebih aman (verified/success/status)
      verified: json['verified'] ?? json['success'] ?? json['status'] ?? false,
      // Cek berbagai kemungkinan key pesan (message/msg/detail)
      message: json['message'] ?? json['msg'] ?? json['detail'] ?? 'Status verifikasi tidak diketahui',
    );
  }
}

class RegistrationResultModel {
   final bool success;
   final String message;
   final Map<String, dynamic>? trainResult;

   RegistrationResultModel({required this.success, required this.message, this.trainResult});

   factory RegistrationResultModel.fromJson(Map<String, dynamic> json) {
     return RegistrationResultModel(
       success: json['success'] ?? false,
       message: json['message'] ?? 'Status registrasi tidak diketahui',
       trainResult: json['train_result'],
     );
   }
}