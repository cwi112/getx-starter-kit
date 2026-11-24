// =============================================================================
// 실전 예제 - View
//
// 실제 프로젝트의 화면 구성 그대로:
//   posts_view.dart / posts_controller.dart / posts_binding.dart / posts_repository.dart / post.dart
// - 목록: PageStateBuilder + RefreshIndicator(당겨서 새로고침)
// - 등록: FAB → controller.createPost() → 결과를 toast 로 안내
// =============================================================================
import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'posts_controller.dart';

class PostsView extends BaseView<PostsController> {
  const PostsView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('실전 예제: 게시글'));

  @override
  Widget? floatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () async {
          await controller.createPost();
          final msg = controller.message.value;
          // await 뒤에 context 를 쓸 때는 화면이 아직 살아 있는지 확인한다.
          if (msg != null && context.mounted) context.toast(msg);
        },
        child: const Icon(Icons.add),
      );

  @override
  Widget body(BuildContext context) {
    return PageStateBuilder(
      state: controller.pageState,
      onRetry: controller.loadPosts,
      success: (_) => RefreshIndicator(
        onRefresh: controller.loadPosts,
        child: Obx(
          () => ListView.separated(
            itemCount: controller.posts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final post = controller.posts[i];
              return ListTile(
                leading: Text('#${post.id}'),
                title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        ),
      ),
    );
  }
}
