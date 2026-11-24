// =============================================================================
// 4. API 와 Failure
//
// 이 파일에서 배우는 것
// - Repository 는 BaseRepository 를 상속하고 safeCall 로 요청을 감싼다.
//   safeCall 이 HTTP 상태 확인 / 예외 처리를 대신 해주므로 try-catch 를 쓰지 않는다.
// - 결과는 Either<Failure, T> 이다.  Right = 성공 값, Left = 실패 이유.
// - Failure 는 sealed class 라서 switch 로 종류별 처리를 빠짐없이 할 수 있다.
//     ResponseFailure : 서버가 4xx/5xx 응답 (statusCode 확인 가능)
//     NetworkFailure  : 인터넷 끊김, 타임아웃 등
//     UnknownFailure  : 응답 파싱 실패 등 그 밖의 오류
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/demo_widgets.dart';
import '../../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Repository: "무엇을 요청하고, 응답을 무엇으로 바꿀지"만 쓴다.
// ---------------------------------------------------------------------------
class ApiDemoRepository extends BaseRepository {
  /// 성공: 200 응답 → Map 에서 title 만 꺼낸다.
  Future<Either<Failure, String>> success() => safeCall(
        () => client.get('/posts/1'),
        parser: (data) => data['title'] as String,
      );

  /// 404: 없는 리소스 → ResponseFailure(404)
  Future<Either<Failure, String>> notFound() => safeCall(
        () => client.get('/posts/0'),
        parser: (data) => data['title'] as String,
      );

  /// 연결 오류: 존재하지 않는 주소 → NetworkFailure
  /// (전체 URL 을 넘기면 ApiClient 의 baseUrl 대신 그 주소로 요청한다)
  Future<Either<Failure, String>> connectionError() => safeCall(
        () => client.get('https://no-such-host.invalid/posts'),
        parser: (data) => data.toString(),
      );

  /// 파싱 오류: 객체(Map)를 목록(List)으로 바꾸려다 실패 → UnknownFailure
  Future<Either<Failure, List<dynamic>>> parseError() => safeCall(
        () => client.get('/posts/1'),
        parser: (data) => data as List<dynamic>,
      );
}

// ---------------------------------------------------------------------------
// Controller: Either 를 fold 해서 화면에 보여줄 값으로 바꾼다.
// ---------------------------------------------------------------------------
class ApiDemoController extends BaseController {
  ApiDemoController(this._repository);

  final ApiDemoRepository _repository;

  final title = ''.obs;
  final detail = ''.obs;
  final isSuccess = RxnBool();

  Future<void> request(String name, Future<Either<Failure, Object>> Function() call) async {
    final result = await runWithLoading(call, text: '$name 요청 중');
    if (result == null) return;

    // fold(실패일 때, 성공일 때)
    result.fold(
      (failure) {
        isSuccess.value = false;
        title.value = '$name → ${failure.runtimeType}';
        detail.value = describe(failure);
      },
      (value) {
        isSuccess.value = true;
        title.value = '$name → 성공';
        detail.value = value.toString();
      },
    );
  }

  /// sealed class + switch: Failure 종류를 하나라도 빠뜨리면 컴파일 오류가 난다.
  String describe(Failure failure) => switch (failure) {
        ResponseFailure(:final statusCode, :final message) => 'HTTP $statusCode\n$message',
        NetworkFailure(:final isConnectionError, :final message) =>
          '${isConnectionError ? '연결 실패' : '네트워크 오류'}\n$message',
        UnknownFailure(:final error, :final message) => '$message\n원인: ${error.runtimeType}',
      };

  void success() => request('성공', _repository.success);
  void notFound() => request('404', _repository.notFound);
  void connectionError() => request('연결 오류', _repository.connectionError);
  void parseError() => request('파싱 오류', _repository.parseError);
}

class ApiDemoBinding extends BaseBinding {
  @override
  void dependencies() {
    // Repository 를 먼저 등록하고, Controller 가 Get.find() 로 받아 간다.
    lazy(() => ApiDemoRepository());
    lazy(() => ApiDemoController(Get.find()));
  }
}

class ApiDemoView extends BaseView<ApiDemoController> {
  const ApiDemoView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('API와 Failure'));

  @override
  Widget body(BuildContext context) {
    return DemoScrollBody(
      children: [
        const DemoHeader(
          icon: Icons.cloud_sync_rounded,
          color: AppColors.rose,
          points: [
            'safeCall이 상태 코드 확인과 예외 처리를 대신함',
            '결과는 Either<Failure, T> (Right 성공 / Left 실패)',
            'Failure 종류별로 switch 처리',
          ],
        ),
        DemoSection(
          title: '요청 보내기',
          description: '실제 API(JSONPlaceholder)를 호출합니다.',
          // 2열 배치. 높이를 고정하지 않아 글자 크기가 커져도 잘리지 않는다.
          child: Column(
            children: [
              _TileRow(
                _RequestTile('성공 (200)', 'GET /posts/1', Icons.check_circle_outline, AppColors.success, controller.success),
                _RequestTile('404', 'GET /posts/0', Icons.search_off_rounded, AppColors.amber, controller.notFound),
              ),
              const SizedBox(height: 10),
              _TileRow(
                _RequestTile('연결 오류', '없는 주소로 요청', Icons.wifi_off_rounded, AppColors.rose, controller.connectionError),
                _RequestTile('파싱 오류', 'Map을 List로 변환', Icons.data_object_rounded, AppColors.violet, controller.parseError),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '결과',
          child: Obx(() {
            final ok = controller.isSuccess.value;
            if (ok == null) {
              return const Text('아직 요청하지 않았습니다.', style: TextStyle(color: AppColors.textWeak));
            }
            final color = ok ? AppColors.success : AppColors.danger;

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.title.value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                        const SizedBox(height: 4),
                        Text(controller.detail.value, style: const TextStyle(height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const DemoSection(
          title: '코드',
          code: '// Repository\n'
              'Future<Either<Failure, String>> getTitle() => safeCall(\n'
              '  () => client.get("/posts/1"),\n'
              '  parser: (data) => data["title"],\n'
              ');\n\n'
              '// Controller\n'
              'result.fold(\n'
              '  (failure) => switch (failure) {\n'
              '    ResponseFailure() => ...,\n'
              '    NetworkFailure() => ...,\n'
              '    UnknownFailure() => ...,\n'
              '  },\n'
              '  (title) => ...,\n'
              ');',
        ),
      ],
    );
  }
}

/// 두 타일을 같은 높이로 나란히 놓는다.
class _TileRow extends StatelessWidget {
  const _TileRow(this.left, this.right);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: left), const SizedBox(width: 10), Expanded(child: right)],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile(this.title, this.subtitle, this.icon, this.color, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textWeak)),
            ],
          ),
        ),
      ),
    );
  }
}
