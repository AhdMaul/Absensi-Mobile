import 'dart:async';

import 'package:get/get.dart';

import '../../services/connectivity_service.dart';

class ConnectivityController extends GetxController {
  final RxBool isOnline = true.obs;
  StreamSubscription<bool>? _sub;

  @override
  void onInit() {
    super.onInit();
    // Ambil service yang sudah didaftarkan di binding
    final service = Get.find<ConnectivityService>();
    _sub = service.connectionStream.listen((value) {
      isOnline.value = value;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
