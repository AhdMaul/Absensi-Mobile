// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // Untuk kDebugMode

class ConnectivityService {
  // Stream controller untuk menyiarkan status koneksi
  final _connectionStreamController = StreamController<bool>.broadcast();
  
  // Getter publik untuk stream-nya
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  ConnectivityService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // 1. Dapatkan status koneksi saat ini saat service dimulai
    // Tipe data 'initialResult' adalah List<ConnectivityResult>
    final initialResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(initialResult);

    // 2. Dengarkan perubahan koneksi di masa mendatang
    // Stream 'onConnectivityChanged' juga mengirim List<ConnectivityResult>
    Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  // Parameter diubah dari 'ConnectivityResult result' 
  // menjadi 'List<ConnectivityResult> resultList'
  void _updateConnectionStatus(List<ConnectivityResult> resultList) {
    if (kDebugMode) {
      print("Status Koneksi Berubah: $resultList");
    }
    
    // Logika baru: Cek apakah ada 'salah satu' koneksi di list
    // yang BUKAN 'none'
    bool isOnline = resultList.any((result) => result != ConnectivityResult.none);
    
    _connectionStreamController.add(isOnline);
  }

  // Opsional: Buat fungsi dispose jika Anda membutuhkannya
  void dispose() {
    _connectionStreamController.close();
  }
}