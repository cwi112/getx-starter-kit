// =============================================================================
// 메뉴 화면: 기능별 예제 화면으로 이동한다.
//
// 이 파일에서 배우는 것
// - 가장 단순한 BaseView / BaseController / BaseBinding 세트
// - Get.toNamed 로 등록된 라우트로 이동하는 방법
//
// 작은 화면은 이렇게 View, Controller, Binding 을 한 파일에 둬도 된다.
// 화면이 커지면 posts/ 예제처럼 파일을 나눈다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';

class DemoMenu {
  const DemoMenu(this.title, this.description, this.route);

  final String title;
  final String description;
  final String route;
}

class HomeController extends BaseController {
  final menus = const [
    DemoMenu('1. BaseView 기본', 'appBar/body 구현, Scaffold 옵션 재정의, 키보드 내리기', Routes.baseView),
    DemoMenu('2. 로딩 오버레이', 'showLoading, runWithLoading, 중복 실행 방지, 커스텀 로딩', Routes.loading),
    DemoMenu('3. PageState', '6가지 상태와 PageStateBuilder 기본/커스텀 화면', Routes.pageState),
    DemoMenu('4. API와 Failure', 'safeCall 로 성공/404/연결 오류/파싱 오류 구분', Routes.api),
    DemoMenu('5. Binding과 라우팅', 'lazy 와 put 의 차이, arguments 전달, 화면 종료 시 해제', Routes.binding),
    DemoMenu('6. 다이얼로그·토스트', 'messageDialog, confirmDialog, toast', Routes.dialog),
    DemoMenu('실전 예제: 게시글 목록', '위 기능을 모두 조합한 목록 조회 + 등록 화면', Routes.posts),
  ];

  void open(DemoMenu menu) => Get.toNamed(menu.route);
}

class HomeBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => HomeController());
  }
}

class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('app_base_getx 예제'));

  @override
  Widget body(BuildContext context) {
    // controller 는 GetView 가 Get.find<HomeController>() 로 찾아준다.
    return ListView.separated(
      itemCount: controller.menus.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final menu = controller.menus[i];
        return ListTile(
          title: Text(menu.title),
          subtitle: Text(menu.description),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => controller.open(menu),
        );
      },
    );
  }
}
