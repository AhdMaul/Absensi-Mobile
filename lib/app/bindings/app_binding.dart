import 'package:get/get.dart';

import '../../services/connectivity_service.dart';
import '../../core/controllers/connectivity_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register services first
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);

    // Register controllers (they can find services via Get.find)
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
  }
}
