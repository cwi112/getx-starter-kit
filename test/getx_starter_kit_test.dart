import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:logger/logger.dart';

// 네트워크 · Failure · 유틸 테스트는 flutter_api_kit 레포에 있다.

class _TestController extends BaseController {
  final pageState = PageState.initial.obs;
}

class _TestView extends BaseView<_TestController> {
  const _TestView();

  @override
  PreferredSizeWidget? appBar(BuildContext context) => null;

  @override
  Widget body(BuildContext context) => const Text('body');
}

void main() {
  setUpAll(() => LoggerUtil.init(logger: Logger(level: Level.off)));
  tearDown(Get.reset);

  group('BaseController', () {
    test('setState 는 Rx 값을 바꾼다', () {
      final c = _TestController();
      c.setState(c.pageState, PageState.success);
      expect(c.pageState.value, PageState.success);
    });

    test('runWithLoading 은 실행 중 loading, 끝나면 success', () async {
      final c = _TestController();
      PageState? during;
      final result = await c.runWithLoading(() async {
        during = c.scaffoldLoadingState.value;
        return 42;
      }, text: '처리 중');

      expect(during, PageState.loading);
      expect(result, 42);
      expect(c.scaffoldLoadingState.value, PageState.success);
      expect(c.loadingText.value, '');
    });

    test('runWithLoading 은 예외를 삼키고 failed 로 끝난다', () async {
      final c = _TestController();
      final result = await c.runWithLoading<int>(() async => throw Exception('boom'));

      expect(result, isNull);
      expect(c.scaffoldLoadingState.value, PageState.failed);
    });

    test('이미 로딩 중이면 runWithLoading 은 중복 실행하지 않는다', () async {
      final c = _TestController()..showLoading();
      var called = false;
      await c.runWithLoading(() async => called = true);
      expect(called, isFalse);
    });
  });

  group('BaseBinding', () {
    test('lazy 는 처음 찾을 때 생성하고, put 은 즉시 생성한다', () {
      final binding = _TestBinding()..dependencies();

      expect(Get.isPrepared<_LazyService>(), isTrue);
      expect(Get.isRegistered<_EagerService>(), isTrue);
      expect(Get.isPrepared<_EagerService>(), isFalse);

      Get.find<_LazyService>();
      expect(Get.isPrepared<_LazyService>(), isFalse);
      expect(binding, isA<Bindings>());
    });
  });

  group('BaseView / PageStateBuilder', () {
    testWidgets('scaffoldLoadingState 가 loading 이면 오버레이를 띄운다', (tester) async {
      final c = Get.put(_TestController());
      await tester.pumpWidget(const GetMaterialApp(home: _TestView()));

      expect(find.text('body'), findsOneWidget);
      expect(find.byType(ScaffoldLoading), findsNothing);

      c.showLoading(text: '잠시만요');
      await tester.pump();
      expect(find.byType(ScaffoldLoading), findsOneWidget);
      expect(find.text('잠시만요'), findsOneWidget);

      c.hideLoading();
      await tester.pump();
      expect(find.byType(ScaffoldLoading), findsNothing);
    });

    testWidgets('PageStateBuilder 는 상태별 화면을 그린다', (tester) async {
      final state = PageState.loading.obs;
      var retried = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PageStateBuilder(
            state: state,
            onRetry: () => retried++,
            success: (_) => const Text('done'),
          ),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      state.value = PageState.failed;
      await tester.pump();
      await tester.tap(find.text('다시 시도'));
      expect(retried, 1);

      state.value = PageState.success;
      await tester.pump();
      expect(find.text('done'), findsOneWidget);
    });
  });
}

class _LazyService {}

class _EagerService {}

class _TestBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => _LazyService());
    put(_EagerService());
  }
}
