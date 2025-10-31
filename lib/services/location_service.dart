// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import '../../config/app_constants.dart'; // Import konstanta

class LocationService {

  // Cek dan minta izin lokasi
  Future<LocationPermission> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi dimatikan. Silakan aktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen, buka pengaturan aplikasi.');
    }
    return permission;
  }

  // Dapatkan posisi saat ini
  Future<Position> getCurrentPosition() async {
    final permission = await _handleLocationPermission();
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        try {
          // Dapatkan lokasi dengan akurasi tinggi
          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            // (Opsional) Tambahkan timeLimit jika perlu
            // timeLimit: const Duration(seconds: 15)
          );
        } catch (e) {
           print("Error getCurrentPosition: $e");
           throw Exception("Gagal mendapatkan lokasi saat ini.");
        }
    } else {
       throw Exception("Izin lokasi tidak memadai.");
    }
  }

  // Hitung jarak ke kantor
  double getDistanceToOffice(double currentLat, double currentLon) {
    return Geolocator.distanceBetween(
      currentLat,
      currentLon,
      AppConstants.officeLatitude,
      AppConstants.officeLongitude,
    );
  }

  // Cek apakah di dalam radius kantor
  bool isWithinOfficeRadius(double distance) {
     return distance <= AppConstants.allowedRadiusMeters;
  }
}