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

import '../../common/demo_widgets.dart';
import '../../theme/app_theme.dart';

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
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('PageState'));

  @override
  Widget body(BuildContext context) {
    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.layers_rounded,
          color: AppColors.teal,
          points: [
            '화면 상태를 Rx<PageState> 하나로 관리',
            'PageStateBuilder가 상태별 화면을 자동 선택',
            'success 외에는 생략하면 기본 화면 사용',
          ],
        ),
        DemoSection(
          title: '상태 바꾸기',
          description: '칩을 눌러 아래 미리보기가 어떻게 바뀌는지 확인하세요.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in PageState.values)
                      ChoiceChip(
                        label: Text(s.name),
                        selected: controller.pageState.value == s,
                        selectedColor: AppColors.teal.withValues(alpha: 0.18),
                        onSelected: (_) => controller.change(s),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('커스텀 빌더 사용'),
                  subtitle: const Text('끄면 패키지 기본 화면, 켜면 직접 만든 화면'),
                  value: controller.useCustomBuilder.value,
                  onChanged: (v) => controller.useCustomBuilder.value = v,
                ),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '미리보기',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Row(
                    children: [
                      StatusPill(text: controller.pageState.value.name, color: AppColors.teal),
                      const Spacer(),
                      Text('다시 시도 ${controller.retryCount.value}회',
                          style: const TextStyle(color: AppColors.textWeak, fontSize: 13)),
                    ],
                  )),
              const SizedBox(height: 12),
              // 상태에 따라 바뀌는 영역
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => controller.useCustomBuilder.value ? _custom() : _default()),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: '사용법',
          code: 'PageStateBuilder(\n'
              '  state: controller.pageState,\n'
              '  onRetry: controller.load,      // 실패 화면의 다시 시도\n'
              '  success: (_) => ListView(...),\n'
              '  empty: (_) => MyEmptyView(),   // 선택: 직접 만든 화면\n'
              ')',
        ),
      ],
    );
  }

  /// 기본 화면 사용: success 와 onRetry 만 넘기면 된다.
  Widget _default() => PageStateBuilder(
        state: controller.pageState,
        onRetry: controller.retry,
        success: (_) => const _SuccessPreview(),
      );

  /// 필요한 상태만 골라서 화면을 바꿀 수 있다. 넘기지 않은 상태는 기본 화면.
  Widget _custom() => PageStateBuilder(
        state: controller.pageState,
        onRetry: controller.retry,
        success: (_) => const _SuccessPreview(),
        loading: (_) => const Center(
          child: SizedBox(width: 160, child: LinearProgressIndicator(color: AppColors.teal)),
        ),
        empty: (_) => const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_rounded, size: 48, color: AppColors.textWeak),
            SizedBox(height: 8),
            StateMessage(title: '아직 등록된 카드가 없어요', description: '카드를 등록해 보세요'),
          ],
        ),
        failed: (_) => StateMessage(
          title: '앗, 문제가 생겼어요',
          retryText: '새로고침',
          onRetry: controller.retry,
        ),
      );
}

class _SuccessPreview extends StatelessWidget {
  const _SuccessPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 56, color: AppColors.success),
          SizedBox(height: 10),
          Text('데이터를 불러왔습니다', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
