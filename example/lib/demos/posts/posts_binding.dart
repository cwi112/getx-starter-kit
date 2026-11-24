import 'package:app_base_getx/app_base_getx.dart';
import 'package:get/get.dart';

import 'posts_controller.dart';
import 'posts_repository.dart';

/// 실전 예제 - Binding: Repository → Controller 순서로 등록한다.
class PostsBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => PostsRepository());
    lazy(() => PostsController(Get.find<PostsRepository>()));
  }
}
