// lib/core/widgets/connectivity_banner.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart'; // Import warna kustom Anda

import '../controllers/connectivity_controller.dart';

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // ConnectivityController didaftarkan di AppBinding
    final controller = Get.find<ConnectivityController>();

    return Obx(() {
      final isOnline = controller.isOnline.value;
      
      // Gunakan Stack sederhana (tidak pakai Positioned)
      // untuk menghindari layout constraints issues
      return Stack(
        children: [
          // Konten utama aplikasi - tetap normal layout
          child,
          
          // Banner offline overlay - hanya render saat offline (tidak pakai Positioned)
          if (!isOnline)
            Material(
              elevation: 2.0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: kErrorColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Tidak Ada Koneksi Internet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}