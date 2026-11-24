// =============================================================================
// 3. PageState 와 PageStateBuilder
//
// 이 파일에서 배우는 것
// - 화면(또는 화면 일부)의 상태를 Rx<PageState> 하나로 관리한다.
//   initial / loading / success / failed / empty / noInternet
// - PageStateBuilder 는 상태에 맞는 위젯을 자동으로 골라 그린다.
//   success 만 필수이고, 나머지는 생략하면 기본 화면(로딩, 실패 + 다시 시도 등)을 쓴다.
// - 한 화면에 상태를 여러 개 둘 수도 있다 (예: 상단 배너 상태, 목록 상태).
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PageStateDemoController extends BaseController {
  final pageState = PageState.success.obs;
  final useCustomBuilder = false.obs;
  final retryCount = 0.obs;

  // setState(대상, 새 상태): 어느 Rx 를 바꾸는지 한눈에 보이도록 BaseController 가 제공
  void change(PageState next) => setState(pageState, next);

  /// 실패 화면의 "다시 시도" 버튼이 호출한다. 실제 앱에서는 여기서 API 를 다시 부른다.
  Future<void> retry() async {
    retryCount.value++;
    setState(pageState, PageState.loading);
    await Future.delayed(const Duration(seconds: 1));
    setState(pageState, PageState.success);
  }
}

class PageStateDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => PageStateDemoController());
  }
}

class PageStateDemoView extends BaseView<PageStateDemoController> {
  const PageStateDemoView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('3. PageState'));

  @override
  Widget body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상태 선택 칩
        Obx(
          () => Wrap(
            spacing: 8,
            children: PageState.values
                .map((s) => ChoiceChip(
                      label: Text(s.name),
                      selected: controller.pageState.value == s,
                      onSelected: (_) => controller.change(s),
                    ))
                .toList(),
          ),
        ).paddingAll(16),
        Obx(
          () => SwitchListTile(
            title: const Text('커스텀 빌더 사용'),
            subtitle: const Text('끄면 패키지 기본 화면, 켜면 직접 만든 화면'),
            value: controller.useCustomBuilder.value,
            onChanged: (v) => controller.useCustomBuilder.value = v,
          ),
        ),
        Obx(() => Text('다시 시도 누른 횟수: ${controller.retryCount.value}').paddingSymmetric(horizontal: 16)),
        const Divider(),
        // 상태에 따라 바뀌는 영역
        Expanded(child: Obx(() => controller.useCustomBuilder.value ? _custom() : _default())),
      ],
    );
  }

  /// 기본 화면 사용: success 와 onRetry 만 넘기면 된다.
  Widget _default() => PageStateBuilder(
        state: controller.pageState,
        onRetry: controller.retry,
        success: (_) => const Center(child: Text('데이터를 불러왔습니다 ✓', style: TextStyle(fontSize: 18))),
      );

  /// 필요한 상태만 골라서 화면을 바꿀 수 있다. 넘기지 않은 상태는 기본 화면.
  Widget _custom() => PageStateBuilder(
        state: controller.pageState,
        onRetry: controller.retry,
        success: (_) => const Center(child: Icon(Icons.check_circle, size: 80, color: Colors.green)),
        loading: (_) => const Center(child: LinearProgressIndicator()),
        empty: (_) => const StateMessage(title: '아직 등록된 카드가 없어요', description: '카드를 등록해 보세요'),
        failed: (_) => StateMessage(
          title: '앗, 문제가 생겼어요',
          retryText: '새로고침',
          onRetry: controller.retry,
        ),
      );
}
