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
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('2. 로딩 오버레이'));

  /// 로딩 화면 교체. BaseView 가 Obx 안에서 호출하므로 Rx 값을 읽으면 바로 반영된다.
  @override
  Widget loadingOverlay(BuildContext context, String text) {
    if (!controller.useCustomOverlay.value) return super.loadingOverlay(context, text);

    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 200, child: LinearProgressIndicator()),
            const Height(16),
            Material(type: MaterialType.transparency, child: Text(text.isEmpty ? '잠시만 기다려 주세요' : text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => SwitchListTile(
            title: const Text('커스텀 로딩 화면 사용'),
            value: controller.useCustomOverlay.value,
            onChanged: (v) => controller.useCustomOverlay.value = v,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: controller.manualLoading, child: const Text('직접 켜고 끄기')),
            FilledButton(onPressed: controller.successTask, child: const Text('runWithLoading 성공')),
            FilledButton(onPressed: controller.failingTask, child: const Text('runWithLoading 실패')),
            OutlinedButton(onPressed: controller.rapidTap, child: const Text('연타 방지 확인')),
          ],
        ).paddingAll(16),
        const Divider(),
        Expanded(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.all(16),
              children: controller.log.map((e) => Text('• $e')).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
