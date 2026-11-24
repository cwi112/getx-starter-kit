import 'package:app_base_getx/app_base_getx.dart';
import 'package:get/get.dart';

import '../home/home_binding.dart';
import '../home/home_view.dart';

abstract class Routes {
  static const home = '/home';
}

abstract class AppPages {
  static const initialRoute = Routes.home;

  static final List<GetPage> routes = [
    basePage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
  ];
}
