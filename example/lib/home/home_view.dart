// =============================================================================
// 메뉴 화면: 기능별 예제 화면으로 이동한다.
//
// 이 파일에서 배우는 것
// - 가장 단순한 BaseView / BaseController / BaseBinding 세트
// - appBar 가 필요 없는 화면은 appBar() 에서 null 을 반환한다.
// - Get.toNamed 로 등록된 라우트로 이동하는 방법
//
// 작은 화면은 이렇게 View, Controller, Binding 을 한 파일에 둬도 된다.
// 화면이 커지면 posts/ 예제처럼 파일을 나눈다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/demo_widgets.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class DemoMenu {
  const DemoMenu(this.title, this.description, this.route, this.icon, this.color);

  final String title;
  final String description;
  final String route;
  final IconData icon;
  final Color color;
}

class HomeController extends BaseController {
  final menus = const [
    DemoMenu('1. BaseView 기본', 'appBar/body 구현, Scaffold 옵션 재정의, 키보드 내리기',
        Routes.baseView, Icons.web_asset_rounded, AppColors.indigo),
    DemoMenu('2. 로딩 오버레이', 'showLoading, runWithLoading, 중복 실행 방지, 커스텀 로딩',
        Routes.loading, Icons.hourglass_top_rounded, AppColors.sky),
    DemoMenu('3. PageState', '6가지 상태와 PageStateBuilder 기본/커스텀 화면',
        Routes.pageState, Icons.layers_rounded, AppColors.teal),
    DemoMenu('4. API와 Failure', 'safeCall 로 성공/404/연결 오류/파싱 오류 구분',
        Routes.api, Icons.cloud_sync_rounded, AppColors.rose),
    DemoMenu('5. Binding과 라우팅', 'lazy 와 put 의 차이, arguments 전달, 화면 종료 시 해제',
        Routes.binding, Icons.account_tree_rounded, AppColors.amber),
    DemoMenu('6. 다이얼로그·토스트', 'messageDialog, confirmDialog, toast',
        Routes.dialog, Icons.chat_bubble_rounded, AppColors.violet),
  ];

  final practice = const DemoMenu('실전 예제: 게시글 목록', '위 기능을 모두 조합한 목록 조회 + 등록 화면',
      Routes.posts, Icons.rocket_launch_rounded, AppColors.slate);

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

  // 앱바 대신 본문에 큰 헤더를 그리므로 null
  @override
  PreferredSizeWidget? appBar(BuildContext context) => null;

  @override
  Widget body(BuildContext context) {
    // controller 는 GetView 가 Get.find<HomeController>() 로 찾아준다.
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const _HeroHeader(),
        const SizedBox(height: 24),
        const _SectionLabel('기능별 예제'),
        for (final menu in controller.menus) ...[
          _MenuCard(menu: menu, onTap: () => controller.open(menu)),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        const _SectionLabel('실전'),
        _MenuCard(menu: controller.practice, onTap: () => controller.open(controller.practice), highlight: true),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('app_base_getx', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'GetX 기반 Flutter 앱의 기본 프레임\n예제를 눌러 기능과 사용법을 확인하세요.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in ['BaseView', 'BaseController', 'BaseBinding', 'safeCall', 'PageState'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWeak)),
      );
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.menu, required this.onTap, this.highlight = false});

  final DemoMenu menu;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final titleColor = highlight ? Colors.white : AppColors.textStrong;
    final descColor = highlight ? Colors.white70 : AppColors.textWeak;

    return Card(
      color: highlight ? AppColors.slate : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconBadge(icon: menu.icon, color: highlight ? Colors.white : menu.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menu.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: titleColor)),
                    const SizedBox(height: 3),
                    Text(menu.description, style: TextStyle(fontSize: 13, color: descColor, height: 1.35)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: descColor),
            ],
          ),
        ),
      ),
    );
  }
}
