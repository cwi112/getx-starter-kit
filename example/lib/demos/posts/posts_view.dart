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

import '../../theme/app_theme.dart';
import 'post.dart';
import 'posts_controller.dart';

class PostsView extends BaseView<PostsController> {
  const PostsView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('게시글'));

  @override
  Widget? floatingActionButton(BuildContext context) => FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          await controller.createPost();
          final msg = controller.message.value;
          // await 뒤에 context 를 쓸 때는 화면이 아직 살아 있는지 확인한다.
          if (msg != null && context.mounted) context.toast(msg);
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text('글쓰기'),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: controller.posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _PostCard(post: controller.posts[i]),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text('${post.id}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textWeak, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
