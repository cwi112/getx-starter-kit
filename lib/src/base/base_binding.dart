import 'package:get/get.dart';

/// 화면 단위 의존성 등록의 공통 부모.
///
/// ```dart
/// class HomeBinding extends BaseBinding {
///   @override
///   void dependencies() {
///     lazy(() => HomeRepository());
///     lazy(() => HomeController(Get.find()));
///   }
/// }
/// ```
abstract class BaseBinding extends Bindings {
  /// 처음 사용할 때 생성한다. [fenix] 가 true 면 해제된 뒤에도 다시 생성할 수 있다.
  void lazy<S>(InstanceBuilderCallback<S> builder, {String? tag, bool fenix = false}) =>
      Get.lazyPut<S>(builder, tag: tag, fenix: fenix);

  /// 즉시 생성해 등록한다.
  S put<S>(S dependency, {String? tag, bool permanent = false}) =>
      Get.put<S>(dependency, tag: tag, permanent: permanent);
}

/// [GetPage] 생성을 짧게 쓰기 위한 헬퍼.
GetPage<T> basePage<T>({
  required String name,
  required GetPageBuilder page,
  Bindings? binding,
  Transition? transition,
}) =>
    GetPage<T>(
      name: name,
      page: page,
      binding: binding,
      transition: transition,
    );
