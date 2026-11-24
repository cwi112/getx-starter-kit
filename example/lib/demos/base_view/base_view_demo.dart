// =============================================================================
// 1. BaseView 기본
//
// 이 파일에서 배우는 것
// - BaseView 를 상속하면 appBar(), body() 두 개만 구현하면 된다.
// - pageColor / bottomNavigationBar / floatingActionButton 등은 필요할 때만 재정의한다.
// - 화면 빈 곳을 탭하면 키보드가 자동으로 내려간다 (unfocusOnTap, 기본 true).
// - Rx 값(.obs)을 Obx(() => ...) 안에서 읽으면 값이 바뀔 때 그 부분만 다시 그려진다.
// =============================================================================
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/demo_widgets.dart';
import '../../theme/app_theme.dart';

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
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('BaseView 기본'));

  // [선택] 배경색. 재정의하지 않으면 테마 기본색.
  @override
  Color? pageColor(BuildContext context) => const Color(0xFFF1F0FF);

  // [선택] 하단 탭바. Obx 로 감싸 탭 선택이 바뀌면 다시 그린다.
  @override
  Widget? bottomNavigationBar(BuildContext context) => Obx(
        () => NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '내 정보'),
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
    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.web_asset_rounded,
          color: AppColors.indigo,
          points: [
            'appBar()와 body()만 구현하면 화면 완성',
            '배경색·하단 탭바·FAB는 필요할 때만 재정의',
            '빈 곳을 탭하면 키보드가 자동으로 내려감',
          ],
        ),
        const DemoSection(
          title: '최소 구현',
          description: '이 두 메서드만 구현하면 로딩 오버레이, SafeArea, 키보드 처리가 자동으로 붙습니다.',
          code: 'class MyView extends BaseView<MyController> {\n'
              '  @override\n'
              '  PreferredSizeWidget? appBar(context) => AppBar(...);\n\n'
              '  @override\n'
              '  Widget body(context) => ...;\n'
              '}',
        ),
        DemoSection(
          title: 'Obx로 부분 갱신',
          description: '오른쪽 아래 + 버튼을 누르면 숫자만 다시 그려집니다.',
          code: 'final count = 0.obs;\nObx(() => Text("\${controller.count.value}"))',
          child: Row(
            children: [
              Obx(
                () => Text(
                  '${controller.count.value}',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.indigo),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('+ 버튼 누른 횟수', style: TextStyle(color: AppColors.textWeak))),
              Obx(() => StatusPill(
                    text: '탭: ${controller.tabIndex.value == 0 ? '홈' : '내 정보'}',
                    color: AppColors.indigo,
                  )),
            ],
          ),
        ),
        const DemoSection(
          title: '키보드 자동 내리기',
          description: '입력창을 누른 뒤 화면의 빈 곳을 탭해 보세요. (끄려면 unfocusOnTap => false)',
          child: TextField(decoration: InputDecoration(hintText: '여기를 눌러 입력', prefixIcon: Icon(Icons.edit))),
        ),
        const DemoSection(
          title: '재정의한 옵션',
          description: '이 화면은 아래 메서드를 재정의했습니다.',
          code: 'Color? pageColor(context) => Color(0xFFF1F0FF);\n'
              'Widget? bottomNavigationBar(context) => NavigationBar(...);\n'
              'Widget? floatingActionButton(context) => FloatingActionButton(...);',
        ),
      ],
    );
  }
}
