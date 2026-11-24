// =============================================================================
// 2. 로딩 오버레이
//
// 이 파일에서 배우는 것
// - controller.showLoading() / hideLoading() : 로딩을 직접 켜고 끈다.
// - controller.runWithLoading(() async {...}) : 작업 동안 자동으로 로딩을 띄우고,
//   예외가 나면 null 을 돌려주며 scaffoldLoadingState 를 failed 로 바꾼다.
// - 로딩 중에 다시 호출하면 실행하지 않는다 → 버튼 연타로 인한 중복 요청 방지.
// - View 에서 loadingOverlay() 를 재정의하면 로딩 화면 디자인을 바꿀 수 있다.
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/demo_widgets.dart';
import '../../theme/app_theme.dart';

class LoadingDemoController extends BaseController {
  final useCustomOverlay = false.obs;
  final log = <String>[].obs;
  int _executed = 0;

  void _write(String msg) => log.insert(0, msg);

  /// 직접 켜고 끄기: 작업이 여러 단계로 나뉘어 문구를 바꿔야 할 때 유용하다.
  Future<void> manualLoading() async {
    showLoading(text: '1단계 진행 중');
    await Future.delayed(const Duration(seconds: 1));
    loadingText.value = '2단계 진행 중'; // 로딩 중 문구만 바꾸기
    await Future.delayed(const Duration(seconds: 1));
    hideLoading();
    _write('showLoading → hideLoading 완료');
  }

  /// runWithLoading: 대부분의 API 호출은 이것 하나면 된다.
  Future<void> successTask() async {
    final result = await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 2));
      return '서버 응답 OK';
    }, text: '저장 중입니다');

    _write('결과: $result / 상태: ${scaffoldLoadingState.value.name}');
  }

  /// 작업 중 예외가 나도 앱이 죽지 않고 null 이 돌아온다.
  Future<void> failingTask() async {
    final result = await runWithLoading<String>(() async {
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('일부러 낸 오류');
    });

    _write('결과: $result / 상태: ${scaffoldLoadingState.value.name}');
  }

  /// 같은 작업을 거의 동시에 3번 호출해도 1번만 실행된다.
  Future<void> rapidTap() async {
    _executed = 0;
    Future<void> task() => runWithLoading(() async {
          _executed++;
          await Future.delayed(const Duration(seconds: 1));
        });

    await Future.wait([task(), task(), task()]);
    _write('3번 호출 → 실제 실행 $_executed번');
  }
}

class LoadingDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => LoadingDemoController());
  }
}

class LoadingDemoView extends BaseView<LoadingDemoController> {
  const LoadingDemoView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('로딩 오버레이'));

  /// 로딩 화면 교체. BaseView 가 Obx 안에서 호출하므로 Rx 값을 읽으면 바로 반영된다.
  @override
  Widget loadingOverlay(BuildContext context, String text) {
    if (!controller.useCustomOverlay.value) return super.loadingOverlay(context, text);

    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(icon: Icons.hourglass_top_rounded, color: AppColors.sky, size: 64),
            const SizedBox(height: 20),
            const SizedBox(width: 180, child: LinearProgressIndicator(color: AppColors.sky)),
            const SizedBox(height: 14),
            Material(
              type: MaterialType.transparency,
              child: Text(text.isEmpty ? '잠시만 기다려 주세요' : text,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textStrong)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget body(BuildContext context) {
    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.hourglass_top_rounded,
          color: AppColors.sky,
          points: [
            'runWithLoading 하나로 로딩 표시·해제·예외 처리',
            '로딩 중 재호출은 무시 → 버튼 연타 방지',
            'loadingOverlay() 재정의로 로딩 디자인 교체',
          ],
        ),
        DemoSection(
          title: '로딩 화면 스타일',
          child: Obx(
            () => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('커스텀 로딩 화면 사용'),
              subtitle: Text(controller.useCustomOverlay.value ? '직접 만든 흰 배경 로딩' : '패키지 기본 로딩'),
              value: controller.useCustomOverlay.value,
              onChanged: (v) => controller.useCustomOverlay.value = v,
            ),
          ),
        ),
        _ActionSection(
          title: 'runWithLoading',
          description: '대부분의 API 호출은 이것 하나면 됩니다. 2초간 "저장 중입니다"를 띄웁니다.',
          code: 'final result = await runWithLoading(\n  () => repository.save(),\n  text: "저장 중입니다",\n);',
          label: '성공 작업 실행',
          icon: Icons.play_arrow_rounded,
          onPressed: controller.successTask,
        ),
        _ActionSection(
          title: '예외가 나면?',
          description: '앱이 죽지 않고 null 이 돌아오며 상태는 failed 가 됩니다.',
          code: 'final result = await runWithLoading(() => throw Exception());\n// result == null',
          label: '실패 작업 실행',
          icon: Icons.error_outline_rounded,
          onPressed: controller.failingTask,
        ),
        _ActionSection(
          title: '직접 켜고 끄기',
          description: '여러 단계로 나뉜 작업에서 중간에 문구를 바꿀 때 씁니다.',
          code: 'showLoading(text: "1단계");\nloadingText.value = "2단계";\nhideLoading();',
          label: '2단계 작업 실행',
          icon: Icons.tune_rounded,
          onPressed: controller.manualLoading,
        ),
        _ActionSection(
          title: '연타 방지',
          description: '같은 작업을 동시에 3번 호출해도 1번만 실행됩니다.',
          label: '3번 연속 호출',
          icon: Icons.touch_app_rounded,
          onPressed: controller.rapidTap,
        ),
        LogPanel(
          logs: controller.log,
          trailing: Obx(() {
            final state = controller.scaffoldLoadingState.value;
            final color = switch (state) {
              PageState.failed => AppColors.danger,
              PageState.success => AppColors.success,
              _ => AppColors.sky,
            };
            return Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(text: 'scaffoldLoadingState: ${state.name}', color: color),
            );
          }),
        ),
      ],
    );
  }
}

/// 설명 + 코드 + 실행 버튼 한 세트
class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.title,
    required this.description,
    this.code,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String? code;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: title,
      description: description,
      code: code,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: AppColors.sky),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
