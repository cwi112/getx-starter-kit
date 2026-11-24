// =============================================================================
// 실전 예제 - Controller
//
// 두 가지 로딩 방식을 상황에 맞게 나눠 쓴다.
// - 목록 조회: 목록 영역만 로딩 → Rx<PageState> + PageStateBuilder
// - 글 등록  : 다른 조작을 막아야 함 → runWithLoading (화면 전체 오버레이)
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:get/get.dart';

import 'post.dart';
import 'posts_repository.dart';

class PostsController extends BaseController {
  // Repository 는 생성자로 받는다 → 테스트에서 가짜 Repository 를 넣을 수 있다.
  PostsController(this._repository);

  final PostsRepository _repository;

  final pageState = PageState.initial.obs;
  final posts = <Post>[].obs;
  final message = RxnString();

  // onReady: 화면이 처음 그려진 직후 한 번 호출된다. 첫 조회는 여기서.
  @override
  void onReady() {
    super.onReady();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(pageState, PageState.loading);

    final result = await _repository.getPosts();

    result.fold(
      // 인터넷 연결 문제는 따로 안내하고, 나머지 실패는 failed 로 처리
      (failure) => setState(
        pageState,
        failure is NetworkFailure && failure.isConnectionError ? PageState.noInternet : PageState.failed,
      ),
      (list) {
        posts.assignAll(list);
        setState(pageState, list.isEmpty ? PageState.empty : PageState.success);
      },
    );
  }

  Future<void> createPost() async {
    final result = await runWithLoading(
      () => _repository.createPost('새 글 ${posts.length + 1}'),
      text: '등록 중입니다',
    );

    result?.fold(
      (failure) => message.value = failure.message,
      (post) {
        posts.insert(0, post);
        message.value = '#${post.id} 등록 완료';
      },
    );
  }
}
