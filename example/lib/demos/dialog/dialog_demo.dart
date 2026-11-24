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
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/demo_widgets.dart';
import '../../theme/app_theme.dart';

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
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('다이얼로그·토스트'));

  @override
  Widget body(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(backgroundColor: AppColors.violet);

    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.violet,
          points: [
            'context 확장 함수로 한 줄 호출',
            'confirmDialog는 예/아니오를 bool로 돌려줌',
            '다이얼로그는 View에서, 그다음 할 일은 Controller에서',
          ],
        ),
        DemoSection(
          title: 'messageDialog',
          description: '확인 버튼 하나짜리 안내 창입니다.',
          code: 'context.messageDialog(content: "저장되었습니다.");',
          child: FilledButton.icon(
            style: buttonStyle,
            onPressed: () => context.messageDialog(content: '저장되었습니다.'),
            icon: const Icon(Icons.info_outline_rounded),
            label: const Text('messageDialog'),
          ),
        ),
        DemoSection(
          title: 'confirmDialog',
          description: '"삭제"를 누르면 1초간 로딩 후 결과가 바뀝니다.',
          code: 'final yes = await context.confirmDialog(\n'
              '  content: "카드를 삭제할까요?",\n'
              '  successText: "삭제",\n'
              ');\n'
              'await controller.onConfirmResult(yes);',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                style: buttonStyle,
                onPressed: () async {
                  final yes = await context.confirmDialog(
                    content: '카드를 삭제할까요?',
                    successText: '삭제',
                    failedText: '취소',
                  );
                  await controller.onConfirmResult(yes);
                },
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('confirmDialog'),
              ),
              const SizedBox(height: 10),
              Obx(() => Row(
                    children: [
                      const Text('결과', style: TextStyle(color: AppColors.textWeak)),
                      const SizedBox(width: 8),
                      StatusPill(text: controller.lastResult.value, color: AppColors.violet),
                    ],
                  )),
            ],
          ),
        ),
        DemoSection(
          title: 'toast',
          description: '화면 아래에 잠깐 보였다 사라집니다.',
          code: 'context.toast("복사되었습니다");',
          child: FilledButton.icon(
            style: buttonStyle,
            onPressed: () => context.toast('복사되었습니다'),
            icon: const Icon(Icons.notifications_none_rounded),
            label: const Text('toast'),
          ),
        ),
        DemoSection(
          title: '화면 크기',
          code: 'context.deviceWidth / context.deviceHeight',
          child: Text(
            '${context.deviceWidth.toStringAsFixed(0)} × ${context.deviceHeight.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
