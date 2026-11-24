# getx_starter_kit

> GetX 기반 Flutter 앱을 새로 시작할 때 바로 가져다 쓰는 **기본 프레임 패키지**

실무에서 결제 앱을 GetX로 개발하며 화면마다 반복하던 코드(로딩 처리, 상태 관리, API 예외 처리, 의존성 등록)를 공통 클래스로 묶어 패키지로 분리했습니다. 새 프로젝트에서는 `pubspec.yaml`에 한 줄을 추가하면 같은 구조로 바로 개발을 시작할 수 있습니다.

![Flutter](https://img.shields.io/badge/Flutter-3.29%2B-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7%2B-0175C2?logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2)
![tests](https://img.shields.io/badge/tests-12%20passed-brightgreen)

## 패키지 구성

이 패키지는 두 계층으로 나뉘어 있습니다.

```
flutter_api_kit      ← 네트워크 · Failure · 유틸 (상태관리 무관, 별도 레포)
      ▲
      │ 의존 + re-export
getx_starter_kit     ← BaseView · BaseController · BaseBinding · PageState (GetX)
```

| 패키지 | 담당 | GetX 필요 |
| --- | --- | --- |
| [flutter_api_kit](https://github.com/jjwwii/flutter-api-kit) | `ApiClient`, `BaseRepository.safeCall`, `Failure`, `ParsingUtil`, `LoggerUtil`, `context` 확장 | 아니요 |
| **getx_starter_kit** (이 레포) | `BaseView`, `BaseController`, `BaseBinding`, `PageState`, `PageStateBuilder`, 공용 위젯 | 예 |

- 네트워크 계층은 상태관리와 무관해서, Provider·Riverpod 프로젝트에서는 `flutter_api_kit`만 가져다 쓸 수 있습니다.
- `getx_starter_kit`은 `flutter_api_kit`을 다시 내보내므로(re-export) **import 한 줄로 두 패키지를 모두** 씁니다.

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
├── getx_starter_kit.dart         # import 한 줄로 전체 사용 (flutter_api_kit 포함)
└── src/
    ├── base/
    │   ├── base_view.dart        # GetView 확장: 로딩 오버레이, 키보드 처리, Scaffold 공통 설정
    │   ├── base_controller.dart  # GetxController 확장: 상태 변경, runWithLoading
    │   ├── base_binding.dart     # Bindings 확장: lazy/put 헬퍼, basePage()
    │   └── page_state.dart       # initial / loading / success / failed / empty / noInternet
    └── widgets/                  # PageStateBuilder, ScaffoldLoading, Height/Width

flutter_api_kit (별도 레포)
    ├── network/                  # ApiClient, BaseRepository.safeCall, Failure
    ├── utils/                    # LoggerUtil, ParsingUtil
    └── extensions/               # context.toast / messageDialog / confirmDialog
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
  getx_starter_kit:
    git:
      url: https://github.com/jjwwii/getx-starter-kit.git
      ref: master
```

```dart
import 'package:getx_starter_kit/getx_starter_kit.dart'; // flutter_api_kit 도 함께 사용 가능
```

`flutter_api_kit`은 자동으로 함께 설치됩니다.

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
flutter test                 # 패키지 7개
cd example && flutter test   # 예제 앱 5개
```

| 대상 | 검증 내용 |
| --- | --- |
| `BaseController` | 상태 변경, `runWithLoading` 성공·실패·중복 실행 방지 |
| `BaseBinding` | `lazy`는 처음 찾을 때, `put`은 즉시 생성 |
| `BaseView` | 로딩 상태에 따라 오버레이 표시/해제 |
| `PageStateBuilder` | 상태별 화면 전환, 다시 시도 버튼 |
| 예제 앱 | 메뉴 → 7개 예제 화면 이동, PageState 전환, 연타 방지, 가짜 Repository로 조회 성공·실패 후 재시도 |

`safeCall`, `Failure`, `ParsingUtil` 테스트(11개)는 [flutter_api_kit](https://github.com/jjwwii/flutter-api-kit)에 있습니다.

## 예제 앱

[`example/`](example)은 기능별 예제 화면 모음입니다. 각 파일 맨 위에 "이 파일에서 배우는 것"을, 핵심 코드 옆에 사용법 주석을 달아 두었습니다.

| 메뉴 | 파일 | 보여주는 것 |
| --- | --- | --- |
| 1. BaseView 기본 | [`base_view_demo.dart`](example/lib/demos/base_view/base_view_demo.dart) | `appBar`/`body` 구현, `pageColor`·`bottomNavigationBar`·`floatingActionButton` 재정의, 키보드 내리기 |
| 2. 로딩 오버레이 | [`loading_demo.dart`](example/lib/demos/loading/loading_demo.dart) | `showLoading`/`hideLoading`, `runWithLoading` 성공·실패, 연타 방지, `loadingOverlay` 커스텀 |
| 3. PageState | [`page_state_demo.dart`](example/lib/demos/page_state/page_state_demo.dart) | 6가지 상태 전환, `PageStateBuilder` 기본/커스텀 화면 비교 |
| 4. API와 Failure | [`api_demo.dart`](example/lib/demos/api/api_demo.dart) | 실제 API로 성공 / 404 / 연결 오류 / 파싱 오류, sealed `Failure` switch 처리 |
| 5. Binding과 라우팅 | [`binding_demo.dart`](example/lib/demos/binding/binding_demo.dart) | `lazy`와 `put` 생성 시점 차이, `arguments` 전달, 화면 종료 시 Controller 해제 |
| 6. 다이얼로그·토스트 | [`dialog_demo.dart`](example/lib/demos/dialog/dialog_demo.dart) | `messageDialog`, `confirmDialog` 결과 처리, `toast` |
| 실전 예제 | [`posts/`](example/lib/demos/posts) | 실제 프로젝트처럼 view / controller / binding / repository / model 파일을 나눈 게시글 목록 + 등록 |

API 예제는 [JSONPlaceholder](https://jsonplaceholder.typicode.com)를 사용합니다.

모든 예제 화면은 같은 구성입니다: **"이 화면에서 배우는 것" 안내 → 기능별 섹션 카드(설명 · 실행 버튼 · 코드 예시) → 실행 로그/결과**. 화면을 직접 조작하면서 바로 아래에서 해당 코드를 확인할 수 있습니다.

### 예제 앱 구조

```
example/lib/
├── main.dart                 # LoggerUtil · ApiClient 초기화, GetMaterialApp
├── routes/app_pages.dart     # Routes 이름 + basePage 등록
├── theme/app_theme.dart      # 공통 테마 (색상 · 카드 · 버튼 · 입력창 · 스낵바 · 다이얼로그)
├── common/demo_widgets.dart  # 공통 컴포넌트 (DemoHeader, DemoSection, CodeBox, StatusPill, LogPanel)
├── home/home_view.dart       # 메뉴 화면
└── demos/
    ├── base_view/  loading/  page_state/  api/  binding/  dialog/   # 기능별 예제 (화면 1개 = 파일 1개)
    └── posts/      # 실전 예제: view / controller / binding / repository / model 분리
```

- 색·모서리·버튼 모양은 `AppTheme` 한곳에서 관리하고, 화면 코드에서는 테마와 공통 컴포넌트를 재사용합니다.
- 작은 예제는 View·Controller·Binding을 한 파일에 두고, 실전 예제는 실제 프로젝트처럼 파일을 나눴습니다.

### 실행

```bash
cd example
fvm flutter run   # 또는 flutter run
```

Android 빌드 설정은 Flutter 3.50 템플릿 기준(Gradle 9.5, AGP 9.3, Kotlin 2.4, Java 17)입니다.

## 기술 스택

- **상태관리 · 라우팅 · DI**: GetX
- **네트워크**: [flutter_api_kit](https://github.com/jjwwii/flutter-api-kit) (Dio, pretty_dio_logger)
- **결과 타입**: dartz `Either`
- **로그**: logger
- **테스트**: flutter_test (단위, 위젯)
