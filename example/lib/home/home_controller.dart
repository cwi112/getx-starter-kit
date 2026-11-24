import 'package:app_base_getx/app_base_getx.dart';
import 'package:get/get.dart';

import 'home_repository.dart';
import 'post.dart';

class HomeController extends BaseController {
  HomeController(this._repository);

  final HomeRepository _repository;

  final pageState = PageState.initial.obs;
  final posts = <Post>[].obs;
  final message = RxnString();

  @override
  void onReady() {
    super.onReady();
    loadPosts();
  }

  /// 목록 조회: 화면 영역만 상태를 바꾼다 (PageStateBuilder).
  Future<void> loadPosts() async {
    setState(pageState, PageState.loading);

    final result = await _repository.getPosts();

    result.fold(
      (failure) => setState(
        pageState,
        failure is NetworkFailure && failure.isConnectionError
            ? PageState.noInternet
            : PageState.failed,
      ),
      (list) {
        posts.assignAll(list);
        setState(pageState, list.isEmpty ? PageState.empty : PageState.success);
      },
    );
  }

  /// 등록: 화면 전체 로딩 오버레이를 띄운다 (runWithLoading).
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
