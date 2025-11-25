import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register HomeController as a singleton (available across app lifetime)
    Get.put<HomeController>(HomeController());
  }
}
