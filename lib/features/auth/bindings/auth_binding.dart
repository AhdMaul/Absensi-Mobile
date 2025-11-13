import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put supaya controller hanya dibuat saat dibutuhkan
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
