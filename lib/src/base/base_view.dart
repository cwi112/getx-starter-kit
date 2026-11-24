import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/scaffold_loading.dart';
import 'base_controller.dart';

/// 모든 화면(View)의 공통 부모.
///
/// [appBar] 와 [body] 만 구현하면 다음이 자동으로 적용된다.
/// - 빈 곳을 탭하면 키보드 내리기
/// - [BaseController.scaffoldLoadingState] 에 따른 전체 화면 로딩 오버레이
/// - SafeArea, 배경색, 하단 바, FAB 등 Scaffold 공통 설정
///
/// ```dart
/// class HomeView extends BaseView<HomeController> {
///   const HomeView({super.key});
///
///   @override
///   PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: const Text('Home'));
///
///   @override
///   Widget body(BuildContext context) => const Text('hello');
/// }
/// ```
abstract class BaseView<C extends BaseController> extends GetView<C> {
  const BaseView({super.key});

  PreferredSizeWidget? appBar(BuildContext context);

  Widget body(BuildContext context);

  /// Scaffold 배경색. `null` 이면 테마 기본값.
  Color? pageColor(BuildContext context) => null;

  Widget? bottomNavigationBar(BuildContext context) => null;

  Widget? floatingActionButton(BuildContext context) => null;

  bool get useSafeArea => true;

  bool get resizeToAvoidBottomInset => true;

  /// 화면 밖을 탭했을 때 키보드를 내릴지 여부
  bool get unfocusOnTap => true;

  /// 로딩 오버레이 위젯. 프로젝트 디자인에 맞게 재정의한다.
  Widget loadingOverlay(BuildContext context, String text) =>
      ScaffoldLoading(loadingText: text);

  /// 로딩 오버레이 위에 추가로 띄울 위젯 (강제 업데이트 안내 등)
  Widget? overlay(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    final extra = overlay(context);

    Widget page = Stack(
      fit: StackFit.expand,
      children: [
        pageScaffold(context),
        Obx(
          () => controller.isScaffoldLoading
              ? loadingOverlay(context, controller.loadingText.value)
              : const SizedBox.shrink(),
        ),
        if (extra != null) extra,
      ],
    );

    if (unfocusOnTap) {
      page = GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: page,
      );
    }

    return page;
  }

  Widget pageScaffold(BuildContext context) {
    final content = body(context);

    return Scaffold(
      backgroundColor: pageColor(context),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar(context),
      body: useSafeArea ? SafeArea(child: content) : content,
      bottomNavigationBar: bottomNavigationBar(context),
      floatingActionButton: floatingActionButton(context),
    );
  }
}
