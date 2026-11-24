import 'package:app_base_getx/app_base_getx.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';

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

class _TestRepository extends BaseRepository {}

Response<dynamic> _response(int status, [dynamic data]) => Response(
      requestOptions: RequestOptions(path: '/test'),
      statusCode: status,
      data: data,
    );

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

  group('BaseRepository.safeCall', () {
    final repo = _TestRepository();

    test('2xx 응답은 parser 결과를 Right 로 준다', () async {
      final r = await repo.safeCall(
        () async => _response(200, {'name': 'kim'}),
        parser: (data) => data['name'] as String,
      );
      expect(r, const Right<Failure, String>('kim'));
    });

    test('2xx 가 아니면 ResponseFailure', () async {
      final r = await repo.safeCall(() async => _response(404), parser: (d) => d);
      final failure = r.fold((l) => l, (_) => null);
      expect(failure, isA<ResponseFailure>());
      expect(failure!.message, '요청한 자원을 찾을 수 없습니다.');
    });

    test('badResponse DioException 은 상태 코드로 ResponseFailure', () async {
      final r = await repo.safeCall(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badResponse,
          response: _response(500),
        ),
        parser: (d) => d,
      );
      final failure = r.fold((l) => l, (_) => null);
      expect(failure, isA<ResponseFailure>());
      expect((failure as ResponseFailure).statusCode, 500);
    });

    test('연결 오류는 NetworkFailure', () async {
      final r = await repo.safeCall(
        () async => throw DioException.connectionError(
          requestOptions: RequestOptions(path: '/test'),
          reason: 'offline',
        ),
        parser: (d) => d,
      );
      final failure = r.fold((l) => l, (_) => null);
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).isConnectionError, isTrue);
    });

    test('parser 예외는 UnknownFailure', () async {
      final r = await repo.safeCall(
        () async => _response(200, 'not a map'),
        parser: (d) => (d as Map)['x'],
      );
      expect(r.fold((l) => l, (_) => null), isA<UnknownFailure>());
    });
  });

  group('ParsingUtil', () {
    test('콤마와 + 기호를 처리하고 실패하면 기본값', () {
      expect(ParsingUtil.stringToInt('1,000'), 1000);
      expect(ParsingUtil.stringToInt('+500'), 500);
      expect(ParsingUtil.stringToInt('abc'), 0);
      expect(ParsingUtil.stringToInt(null), 0);
      expect(ParsingUtil.stringToDouble('1.5'), 1.5);
      expect(ParsingUtil.stringToBigInt('99999999999999999999'),
          BigInt.parse('99999999999999999999'));
    });

    test('jsonToList 는 null 이면 빈 리스트', () {
      expect(ParsingUtil.jsonToList<int>(null, (j) => j['v'] as int), isEmpty);
      expect(
        ParsingUtil.jsonToList<int>([
          {'v': 1},
          {'v': 2},
        ], (j) => j['v'] as int),
        [1, 2],
      );
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
