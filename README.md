# app_base_getx

> GetX 기반 Flutter 앱을 새로 시작할 때 바로 가져다 쓰는 **기본 프레임 패키지**

실무에서 결제 앱을 GetX로 개발하며 화면마다 반복하던 코드(로딩 처리, 상태 관리, API 예외 처리, 의존성 등록)를 공통 클래스로 묶어 패키지로 분리했습니다. 새 프로젝트에서는 `pubspec.yaml`에 한 줄을 추가하면 같은 구조로 바로 개발을 시작할 수 있습니다.

![Flutter](https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7%2B-0175C2?logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2)
![tests](https://img.shields.io/badge/tests-15%20passed-brightgreen)

## 왜 만들었나

| 문제 (기존 프로젝트) | 해결 (이 패키지) |
| --- | --- |
| 화면마다 로딩 오버레이·키보드 내리기·SafeArea 코드를 반복 작성 | `BaseView`가 공통 처리하고, 각 화면은 `appBar`와 `body`만 구현 |
| API 호출마다 `try/catch`, 상태 코드 확인, 로딩 on/off를 직접 작성 | `BaseRepository.safeCall`과 `BaseController.runWithLoading`으로 한 줄 처리 |
| 실패 원인이 `void`/문자열로 반환되어 화면에서 구분 불가 | `Either<Failure, T>`와 sealed `Failure`(응답·네트워크·기타)로 타입 구분 |
| 화면 상태(로딩/성공/실패/빈 화면)별 분기를 매번 `if`로 작성 | `PageState` enum과 `PageStateBuilder`로 선언적으로 처리 |
| 프로젝트 전용 의존성(Firebase, flavor, 사내 API 규격)이 공통 코드에 섞여 있음 | 공통 부분만 추출하고, 프로젝트별 설정은 재정의(override)로 주입 |

## 구조

```
lib/
├── app_base_getx.dart            # import 한 줄로 전체 사용
└── src/
    ├── base/
    │   ├── base_view.dart        # GetView 확장: 로딩 오버레이, 키보드 처리, Scaffold 공통 설정
    │   ├── base_controller.dart  # GetxController 확장: 상태 변경, runWithLoading
    │   ├── base_binding.dart     # Bindings 확장: lazy/put 헬퍼, basePage()
    │   └── page_state.dart       # initial / loading / success / failed / empty / noInternet
    ├── network/
    │   ├── api_client.dart       # Dio 싱글턴 (baseUrl, 공통 헤더, 타임아웃, 로그)
    │   ├── base_repository.dart  # safeCall → Either<Failure, T>
    │   └── failure.dart          # ResponseFailure / NetworkFailure / UnknownFailure
    ├── widgets/                  # PageStateBuilder, ScaffoldLoading, Height/Width
    ├── extensions/               # context.toast / messageDialog / confirmDialog
    └── utils/                    # LoggerUtil, ParsingUtil
```

데이터 흐름은 다음과 같습니다.

```
View (BaseView) ──Obx──▶ Controller (BaseController) ──▶ Repository (BaseRepository) ──▶ ApiClient (Dio)
       ▲                        │  Rx<PageState>                    │ Either<Failure, T>
       └──── PageStateBuilder ◀─┘                                   └─ 예외 → Failure 변환
```

## 설치

```yaml
dependencies:
  app_base_getx:
    git:
      url: https://github.com/jjwwii/app-base-getx.git
      ref: master
```

## 사용법

### 1. 앱 시작

```dart
void main() {
  LoggerUtil.init();
  ApiClient.init(
    baseUrl: 'https://api.example.com',
    headers: {'X-APP-VERSION': '1.0.0'},
  );
  runApp(GetMaterialApp(initialRoute: AppPages.initialRoute, getPages: AppPages.routes));
}
```

### 2. Repository: 요청과 변환만 작성

```dart
class HomeRepository extends BaseRepository {
  Future<Either<Failure, List<Post>>> getPosts() => safeCall(
        () => client.get('/posts'),
        parser: (data) => ParsingUtil.jsonToList(data, Post.fromJson),
      );
}
```

### 3. Controller: 상태만 관리

```dart
class HomeController extends BaseController {
  HomeController(this._repository);
  final HomeRepository _repository;

  final pageState = PageState.initial.obs;
  final posts = <Post>[].obs;

  Future<void> loadPosts() async {
    setState(pageState, PageState.loading);
    (await _repository.getPosts()).fold(
      (failure) => setState(pageState, PageState.failed),
      (list) {
        posts.assignAll(list);
        setState(pageState, list.isEmpty ? PageState.empty : PageState.success);
      },
    );
  }

  // 화면 전체 로딩 오버레이가 필요한 작업
  Future<void> submit() => runWithLoading(() => _repository.submit(), text: '등록 중입니다');
}
```

### 4. Binding / Route

```dart
class HomeBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => HomeRepository());
    lazy(() => HomeController(Get.find()));
  }
}

basePage(name: '/home', page: () => const HomeView(), binding: HomeBinding());
```

### 5. View: appBar와 body만 구현

```dart
class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('Home'));

  @override
  Widget body(BuildContext context) => PageStateBuilder(
        state: controller.pageState,
        onRetry: controller.loadPosts,
        success: (_) => Obx(() => ListView(children: controller.posts.map(PostTile.new).toList())),
      );
}
```

로딩 화면, 배경색, 하단 바, FAB, 강제 업데이트 같은 오버레이는 `loadingOverlay()`, `pageColor()`, `bottomNavigationBar()`, `floatingActionButton()`, `overlay()`를 재정의해서 프로젝트에 맞게 바꿀 수 있습니다.

## 테스트

공통 코드는 모든 화면이 의존하기 때문에, 핵심 동작을 단위·위젯 테스트로 검증했습니다.

```bash
flutter test            # 패키지 13개
cd example && flutter test   # 예제 앱 2개
```

| 대상 | 검증 내용 |
| --- | --- |
| `BaseController` | 상태 변경, `runWithLoading` 성공·실패·중복 실행 방지 |
| `BaseRepository.safeCall` | 2xx 성공, 4xx/5xx → `ResponseFailure`, 연결 오류 → `NetworkFailure`, 파싱 오류 → `UnknownFailure` |
| `ParsingUtil` | 콤마·부호가 있는 문자열, null, 잘못된 값 처리 |
| `BaseView` | 로딩 상태에 따라 오버레이 표시/해제 |
| `PageStateBuilder` | 상태별 화면 전환, 다시 시도 버튼 |
| 예제 앱 | 가짜 Repository로 조회 성공, 실패 후 재시도 흐름 |

## 예제 앱

[`example/`](example)은 [JSONPlaceholder](https://jsonplaceholder.typicode.com) API로 게시글 목록 조회(화면 영역 상태 처리)와 등록(화면 전체 로딩 오버레이)을 보여줍니다.

```bash
cd example
flutter run
```

## 기술 스택

- **상태관리 · 라우팅 · DI**: GetX
- **네트워크**: Dio, pretty_dio_logger
- **결과 타입**: dartz `Either`
- **로그**: logger
- **테스트**: flutter_test (단위, 위젯)
