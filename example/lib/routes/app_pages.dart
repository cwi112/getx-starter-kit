// =============================================================================
// 라우트 등록
//
// 이 파일에서 배우는 것
// - 화면 이름(Routes)과 화면+Binding 묶음(AppPages)을 한곳에서 관리하는 방법
// - basePage() 로 GetPage 를 짧게 등록하는 방법
//
// 새 화면을 추가할 때: Routes 에 이름 추가 → AppPages.routes 에 basePage 한 줄 추가
// =============================================================================
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:get/get.dart';

import '../demos/api/api_demo.dart';
import '../demos/base_view/base_view_demo.dart';
import '../demos/binding/binding_demo.dart';
import '../demos/dialog/dialog_demo.dart';
import '../demos/loading/loading_demo.dart';
import '../demos/page_state/page_state_demo.dart';
import '../demos/posts/posts_binding.dart';
import '../demos/posts/posts_view.dart';
import '../home/home_view.dart';

abstract class Routes {
  static const home = '/';
  static const baseView = '/base-view';
  static const loading = '/loading';
  static const pageState = '/page-state';
  static const api = '/api';
  static const binding = '/binding';
  static const bindingDetail = '/binding/detail';
  static const dialog = '/dialog';
  static const posts = '/posts';
}

abstract class AppPages {
  static const initialRoute = Routes.home;

  static final List<GetPage> routes = [
    basePage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    basePage(name: Routes.baseView, page: () => const BaseViewDemoView(), binding: BaseViewDemoBinding()),
    basePage(name: Routes.loading, page: () => const LoadingDemoView(), binding: LoadingDemoBinding()),
    basePage(name: Routes.pageState, page: () => const PageStateDemoView(), binding: PageStateDemoBinding()),
    basePage(name: Routes.api, page: () => const ApiDemoView(), binding: ApiDemoBinding()),
    basePage(name: Routes.binding, page: () => const BindingDemoView(), binding: BindingDemoBinding()),
    // transition 으로 화면 전환 애니메이션을 화면별로 지정할 수 있다.
    basePage(
      name: Routes.bindingDetail,
      page: () => const BindingDetailView(),
      binding: BindingDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    basePage(name: Routes.dialog, page: () => const DialogDemoView(), binding: DialogDemoBinding()),
    basePage(name: Routes.posts, page: () => const PostsView(), binding: PostsBinding()),
  ];
}
