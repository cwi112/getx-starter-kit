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
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

/// 생성 시각을 기억하는 예시 서비스
class DemoService {
  DemoService(this.name) : createdAt = DateTime.now();

  final String name;
  final DateTime createdAt;

  String get createdTime => createdAt.toIso8601String().substring(11, 19);
}

class BindingDemoController extends BaseController {
  final lazyStatus = ''.obs;
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
    lazyStatus.value = Get.isPrepared<DemoService>(tag: 'lazy')
        ? '아직 생성 안 됨'
        : '생성됨 (${Get.find<DemoService>(tag: 'lazy').createdTime})';
  }

  /// lazy 로 등록한 객체는 이 시점에 처음 만들어진다.
  void useLazyService() {
    Get.find<DemoService>(tag: 'lazy');
    refreshStatus();
  }

  String get eagerStatus => '생성됨 (${Get.find<DemoService>(tag: 'eager').createdTime})';

  /// arguments 로 값을 넘기고, 상세 화면이 닫히면(await 이후) 돌아온 결과를 처리한다.
  Future<void> openDetail() async {
    await Get.toNamed(Routes.bindingDetail, arguments: message.text);
    // 상세 화면이 닫히면 BindingDetailController.onClose 가 이미 호출된 상태다.
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
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('5. Binding과 라우팅'));

  @override
  Widget body(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('lazy vs put', style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(title: const Text('put 으로 등록'), subtitle: Text(controller.eagerStatus)),
        Obx(() => ListTile(title: const Text('lazy 로 등록'), subtitle: Text(controller.lazyStatus.value))),
        FilledButton(onPressed: controller.useLazyService, child: const Text('lazy 서비스 사용하기 (Get.find)')),
        const Divider(height: 40),
        const Text('arguments 전달', style: TextStyle(fontWeight: FontWeight.bold)),
        const Height(8),
        TextField(
          controller: controller.message,
          decoration: const InputDecoration(labelText: '상세 화면에 넘길 값', border: OutlineInputBorder()),
        ),
        const Height(8),
        FilledButton(onPressed: controller.openDetail, child: const Text('상세 화면 열기')),
        const Height(8),
        // 상세 화면을 닫으면 BindingDetailController.onClose 로그가 콘솔에 찍힌다.
        Obx(() => Text('상세 화면에서 돌아온 횟수: ${controller.detailClosedCount.value}')),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('받은 값'),
          const Height(8),
          Text(controller.received, style: Theme.of(context).textTheme.headlineSmall),
          const Height(24),
          OutlinedButton(onPressed: Get.back, child: const Text('뒤로 가기')),
        ],
      ),
    );
  }
}
