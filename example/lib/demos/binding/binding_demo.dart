// =============================================================================
// 5. Binding 과 라우팅
//
// 이 파일에서 배우는 것
// - Binding 은 "이 화면에 들어갈 때 필요한 객체"를 등록하는 곳이다.
//     lazy(() => X())  : 처음 Get.find<X>() 할 때 생성 (대부분 이것을 쓴다)
//     put(X())         : Binding 이 실행되는 즉시 생성
// - 화면을 닫으면 그 화면의 Binding 으로 등록한 Controller 는 자동으로 삭제된다 (onClose 호출).
// - Get.toNamed(경로, arguments: 값) 으로 다음 화면에 값을 넘기고,
//   다음 화면의 Binding 에서 Get.arguments 로 받는다.
// =============================================================================
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/demo_widgets.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';

/// 생성 시각을 기억하는 예시 서비스
class DemoService {
  DemoService(this.name) : createdAt = DateTime.now();

  final String name;
  final DateTime createdAt;

  String get createdTime => createdAt.toIso8601String().substring(11, 19);
}

class BindingDemoController extends BaseController {
  final lazyCreated = false.obs;
  final lazyTime = ''.obs;
  final detailClosedCount = 0.obs;
  final message = TextEditingController(text: '안녕하세요');

  @override
  void onInit() {
    super.onInit();
    refreshStatus();
  }

  // Controller 가 삭제될 때 TextEditingController 같은 자원을 정리한다.
  @override
  void onClose() {
    message.dispose();
    super.onClose();
  }

  /// Get.isPrepared: lazy 로 등록만 되고 아직 생성되지 않았으면 true
  void refreshStatus() {
    lazyCreated.value = !Get.isPrepared<DemoService>(tag: 'lazy');
    if (lazyCreated.value) lazyTime.value = Get.find<DemoService>(tag: 'lazy').createdTime;
  }

  /// lazy 로 등록한 객체는 이 시점에 처음 만들어진다.
  void useLazyService() {
    Get.find<DemoService>(tag: 'lazy');
    refreshStatus();
  }

  String get eagerTime => Get.find<DemoService>(tag: 'eager').createdTime;

  /// arguments 로 값을 넘기고, 상세 화면이 닫히면(await 이후) 돌아온 결과를 처리한다.
  Future<void> openDetail() async {
    await Get.toNamed(Routes.bindingDetail, arguments: message.text);
    // 상세 화면이 닫히면 BindingDetailController.onClose 가 호출된다.
    detailClosedCount.value++;
  }
}

class BindingDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    put(DemoService('eager'), tag: 'eager'); // 지금 바로 생성
    lazy(() => DemoService('lazy'), tag: 'lazy'); // 처음 찾을 때 생성
    lazy(() => BindingDemoController());
  }
}

class BindingDemoView extends BaseView<BindingDemoController> {
  const BindingDemoView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('Binding과 라우팅'));

  @override
  Widget body(BuildContext context) {
    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.account_tree_rounded,
          color: AppColors.amber,
          points: [
            'lazy는 처음 사용할 때, put은 즉시 생성',
            'arguments로 다음 화면에 값 전달',
            '화면을 닫으면 Controller 자동 해제 (onClose)',
          ],
        ),
        DemoSection(
          title: 'lazy vs put',
          description: '이 화면의 Binding 에서 두 서비스를 서로 다른 방식으로 등록했습니다.',
          code: "put(DemoService('eager'), tag: 'eager');\n"
              "lazy(() => DemoService('lazy'), tag: 'lazy');",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ServiceRow(
                label: 'put 으로 등록',
                pill: const StatusPill(text: '생성됨', color: AppColors.success),
                time: controller.eagerTime,
              ),
              const Divider(height: 20),
              Obx(() => _ServiceRow(
                    label: 'lazy 로 등록',
                    pill: controller.lazyCreated.value
                        ? const StatusPill(text: '생성됨', color: AppColors.success)
                        : const StatusPill(text: '대기 중', color: AppColors.textWeak),
                    time: controller.lazyCreated.value ? controller.lazyTime.value : '-',
                  )),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
                onPressed: controller.useLazyService,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('lazy 서비스 사용하기 (Get.find)'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'arguments 전달',
          description: '입력한 값을 상세 화면으로 넘깁니다. 상세 화면을 닫으면 그 Controller 가 해제됩니다.',
          code: "Get.toNamed('/binding/detail', arguments: text);\n\n"
              '// 상세 화면 Binding\n'
              'lazy(() => DetailController(Get.arguments));',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller.message,
                decoration: const InputDecoration(hintText: '상세 화면에 넘길 값', prefixIcon: Icon(Icons.send_rounded)),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.amber),
                onPressed: controller.openDetail,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('상세 화면 열기'),
              ),
              const SizedBox(height: 10),
              Obx(() => Text('상세 화면에서 돌아온 횟수: ${controller.detailClosedCount.value}',
                  style: const TextStyle(color: AppColors.textWeak))),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.label, required this.pill, required this.time});

  final String label;
  final Widget pill;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text(time, style: const TextStyle(color: AppColors.textWeak, fontFamily: 'monospace')),
        const SizedBox(width: 10),
        pill,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 상세 화면: Binding 에서 Get.arguments 를 꺼내 Controller 에 생성자로 넘긴다.
// ---------------------------------------------------------------------------
class BindingDetailController extends BaseController {
  BindingDetailController(this.received);

  final String received;

  @override
  void onClose() {
    logger.i('BindingDetailController 해제됨');
    super.onClose();
  }
}

class BindingDetailBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => BindingDetailController(Get.arguments as String? ?? ''));
  }
}

class BindingDetailView extends BaseView<BindingDetailController> {
  const BindingDetailView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('상세 화면'));

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconBadge(icon: Icons.mark_email_read_rounded, color: AppColors.amber, size: 56),
              const SizedBox(height: 16),
              const Text('Get.arguments 로 받은 값', style: TextStyle(color: AppColors.textWeak)),
              const SizedBox(height: 6),
              Text(controller.received,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('뒤로 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
