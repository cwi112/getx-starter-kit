// =============================================================================
// 6. 다이얼로그 · 토스트
//
// 이 파일에서 배우는 것
// - BuildContext 확장 함수로 어디서든 짧게 호출한다.
//     context.messageDialog(content: ...)          : 확인 버튼 하나
//     await context.confirmDialog(content: ...)    : 예 → true, 아니오/바깥 탭 → false
//     context.toast('메시지')                        : 화면 아래 잠깐 표시
// - context 는 View 에만 있으므로, 다이얼로그는 View 에서 띄우고
//   그 결과로 할 일(삭제, 저장 등)은 Controller 메서드로 넘긴다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogDemoController extends BaseController {
  final lastResult = '아직 없음'.obs;

  /// 확인 다이얼로그 결과를 받아 처리하는 예
  Future<void> onConfirmResult(bool yes) async {
    if (!yes) {
      lastResult.value = '취소했습니다';
      return;
    }
    // 실제 앱이라면 여기서 삭제 API 호출
    await runWithLoading(() => Future.delayed(const Duration(seconds: 1)), text: '삭제 중');
    lastResult.value = '삭제했습니다';
  }
}

class DialogDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => DialogDemoController());
  }
}

class DialogDemoView extends BaseView<DialogDemoController> {
  const DialogDemoView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('6. 다이얼로그·토스트'));

  @override
  Widget body(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton(
          onPressed: () => context.messageDialog(content: '저장되었습니다.'),
          child: const Text('messageDialog'),
        ),
        const Height(8),
        FilledButton(
          onPressed: () async {
            final yes = await context.confirmDialog(
              content: '카드를 삭제할까요?',
              successText: '삭제',
              failedText: '취소',
            );
            await controller.onConfirmResult(yes);
          },
          child: const Text('confirmDialog'),
        ),
        const Height(8),
        FilledButton(
          onPressed: () => context.toast('복사되었습니다'),
          child: const Text('toast'),
        ),
        const Height(24),
        Obx(() => Text('확인 다이얼로그 결과: ${controller.lastResult.value}')),
        const Height(8),
        Text('화면 크기: ${context.deviceWidth.toStringAsFixed(0)} × ${context.deviceHeight.toStringAsFixed(0)}'),
      ],
    );
  }
}
