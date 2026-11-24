import 'package:app_base_getx/app_base_getx.dart';
import 'package:example/home/home_controller.dart';
import 'package:example/home/home_repository.dart';
import 'package:example/home/home_view.dart';
import 'package:example/home/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeRepository extends HomeRepository {
  _FakeRepository(this.result);

  Either<Failure, List<Post>> result;

  @override
  Future<Either<Failure, List<Post>>> getPosts() async => result;
}

void main() {
  tearDown(Get.reset);

  testWidgets('목록 조회 성공 시 게시글을 보여준다', (tester) async {
    Get.put(HomeController(_FakeRepository(const Right([
      Post(id: 1, title: '첫 글', body: '내용'),
    ]))));

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pumpAndSettle();

    expect(find.text('첫 글'), findsOneWidget);
  });

  testWidgets('실패하면 다시 시도 버튼이 보이고, 누르면 다시 조회한다', (tester) async {
    final repo = _FakeRepository(Left(ResponseFailure(500)));
    Get.put(HomeController(repo));

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));
    await tester.pumpAndSettle();
    expect(find.text('다시 시도'), findsOneWidget);

    repo.result = const Right([Post(id: 2, title: '복구됨', body: '')]);
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();

    expect(find.text('복구됨'), findsOneWidget);
  });
}
