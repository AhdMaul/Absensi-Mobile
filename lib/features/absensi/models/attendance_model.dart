import 'dart:convert';

class AttendanceModel {
  final int? id;
  final int userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; 
  final String verificationMethod;
  final double? distanceFromOffice;
  final String? note;

  AttendanceModel({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    required this.verificationMethod,
    this.distanceFromOffice,
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      userId: json['user_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'IN',
      verificationMethod: json['verification_method'] ?? 'face_recognition',
      distanceFromOffice: json['distance_from_office'] != null
          ? (json['distance_from_office'] as num).toDouble()
          : null,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'verification_method': verificationMethod,
      'distance_from_office': distanceFromOffice,
      'note': note,
    };
  }

  static String encodeList(List<AttendanceModel> list) =>
      jsonEncode(list.map((a) => a.toJson()).toList());

  static List<AttendanceModel> decodeList(String jsonStr) {
    final List data = jsonDecode(jsonStr);
    return data.map((e) => AttendanceModel.fromJson(e)).toList();
  }
}
