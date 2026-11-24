import 'package:app_base_getx/app_base_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('app_base_getx'));

  @override
  Widget? floatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () async {
          await controller.createPost();
          final msg = controller.message.value;
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
