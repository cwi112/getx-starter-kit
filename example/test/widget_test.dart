import 'package:app_base_getx/app_base_getx.dart';
import 'package:example/demos/loading/loading_demo.dart';
import 'package:example/demos/page_state/page_state_demo.dart';
import 'package:example/demos/posts/post.dart';
import 'package:example/demos/posts/posts_controller.dart';
import 'package:example/demos/posts/posts_repository.dart';
import 'package:example/demos/posts/posts_view.dart';
import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeRepository extends PostsRepository {
  _FakeRepository(this.result);

  Either<Failure, List<Post>> result;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async => result;
}

void main() {
  tearDown(Get.reset);

  testWidgets('메뉴에서 각 예제 화면으로 이동한다', (tester) async {
    // 실제 폰과 비슷한 화면 크기 (400 x 889)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // 메뉴 제목 → 그 화면에 있어야 하는 문구
    final menus = {
      '1. BaseView 기본': '+ 버튼 누른 횟수',
      '2. 로딩 오버레이': '커스텀 로딩 화면 사용',
      '3. PageState': '커스텀 빌더 사용',
      '4. API와 Failure': '아직 요청하지 않았습니다.',
      '5. Binding과 라우팅': 'lazy vs put',
      '6. 다이얼로그·토스트': 'messageDialog',
      '실전 예제: 게시글 목록': '글쓰기',
    };

    for (final entry in menus.entries) {
      final menu = find.text(entry.key);
      await tester.scrollUntilVisible(menu, 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets, reason: entry.key);

      Get.back();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('PageState 예제: 칩으로 상태를 바꾸면 화면이 바뀐다', (tester) async {
    Get.put(PageStateDemoController());
    await tester.pumpWidget(const GetMaterialApp(home: PageStateDemoView()));

    await tester.tap(find.text('empty'));
    await tester.pump();
    expect(find.text('표시할 데이터가 없습니다'), findsOneWidget);

    await tester.tap(find.text('failed'));
    await tester.pump();
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('로딩 예제: 연타해도 한 번만 실행된다', (tester) async {
    final c = Get.put(LoadingDemoController());
    await tester.pumpWidget(const GetMaterialApp(home: LoadingDemoView()));

    final future = c.rapidTap();
    await tester.pump();
    expect(find.byType(ScaffoldLoading), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await future;
    expect(c.log.first, '3번 호출 → 실제 실행 1번');
  });

  testWidgets('게시글 예제: 조회 성공 시 목록을 보여준다', (tester) async {
    Get.put(PostsController(_FakeRepository(const Right([
      Post(id: 1, title: '첫 글', body: '내용'),
    ]))));

    await tester.pumpWidget(const GetMaterialApp(home: PostsView()));
    await tester.pumpAndSettle();

    expect(find.text('첫 글'), findsOneWidget);
  });

  testWidgets('게시글 예제: 실패하면 다시 시도로 복구한다', (tester) async {
    final repo = _FakeRepository(Left(ResponseFailure(500)));
    Get.put(PostsController(repo));

    await tester.pumpWidget(const GetMaterialApp(home: PostsView()));
    await tester.pumpAndSettle();
    expect(find.text('다시 시도'), findsOneWidget);

    repo.result = const Right([Post(id: 2, title: '복구됨', body: '')]);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('복구됨'), findsOneWidget);
  });
}
