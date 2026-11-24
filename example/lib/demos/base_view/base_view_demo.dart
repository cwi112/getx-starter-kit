// =============================================================================
// 1. BaseView 기본
//
// 이 파일에서 배우는 것
// - BaseView 를 상속하면 appBar(), body() 두 개만 구현하면 된다.
// - pageColor / bottomNavigationBar / floatingActionButton 등은 필요할 때만 재정의한다.
// - 화면 빈 곳을 탭하면 키보드가 자동으로 내려간다 (unfocusOnTap, 기본 true).
// - Rx 값(.obs)을 Obx(() => ...) 안에서 읽으면 값이 바뀔 때 그 부분만 다시 그려진다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BaseViewDemoController extends BaseController {
  // .obs 를 붙이면 관찰 가능한 값(Rx)이 된다.
  final count = 0.obs;
  final tabIndex = 0.obs;

  void increase() => count.value++;

  void changeTab(int index) => tabIndex.value = index;
}

class BaseViewDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => BaseViewDemoController());
  }
}

class BaseViewDemoView extends BaseView<BaseViewDemoController> {
  const BaseViewDemoView({super.key});

  // [필수] 앱바. 앱바가 없는 화면이면 null 을 반환한다.
  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('1. BaseView 기본'));

  // [선택] 배경색. 재정의하지 않으면 테마 기본색.
  @override
  Color? pageColor(BuildContext context) => Colors.indigo.shade50;

  // [선택] 하단 탭바. Obx 로 감싸 탭 선택이 바뀌면 다시 그린다.
  @override
  Widget? bottomNavigationBar(BuildContext context) => Obx(
        () => NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: '홈'),
            NavigationDestination(icon: Icon(Icons.person), label: '내 정보'),
          ],
        ),
      );

  // [선택] 플로팅 버튼
  @override
  Widget? floatingActionButton(BuildContext context) =>
      FloatingActionButton(onPressed: controller.increase, child: const Icon(Icons.add));

  // [선택] SafeArea 를 끄고 싶으면 false (예: 상단까지 이미지를 채우는 화면)
  @override
  bool get useSafeArea => true;

  // [필수] 본문
  @override
  Widget body(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('아래 입력창을 누른 뒤 빈 곳을 탭하면 키보드가 내려갑니다.'),
        const Height(12),
        const TextField(decoration: InputDecoration(labelText: '입력해 보세요', border: OutlineInputBorder())),
        const Height(30),
        // count 가 바뀔 때 이 Text 만 다시 그려진다.
        Obx(() => Text('+ 버튼 누른 횟수: ${controller.count.value}', style: const TextStyle(fontSize: 18))),
        const Height(12),
        Obx(() => Text('선택된 탭: ${controller.tabIndex.value == 0 ? '홈' : '내 정보'}')),
      ],
    );
  }
}
