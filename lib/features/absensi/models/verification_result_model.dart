class VerificationResultModel {
  final bool verified;
  final String message;


  VerificationResultModel({
    required this.verified,
    required this.message,
    // this.recognizedUserName,
  });

  factory VerificationResultModel.fromJson(Map<String, dynamic> json) {
    return VerificationResultModel(
      verified: json['verified'] ?? false,
      message: json['message'] ?? 'Status verifikasi tidak diketahui',
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