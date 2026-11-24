import 'package:app_base_getx/app_base_getx.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import 'home_repository.dart';

class HomeBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => HomeRepository());
    lazy(() => HomeController(Get.find<HomeRepository>()));
  }
}
