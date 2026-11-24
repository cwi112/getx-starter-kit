import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../base/page_state.dart';

/// `Rx<PageState>` 값에 따라 화면을 바꿔 그린다.
///
/// success 외의 빌더를 생략하면 기본 위젯(로딩 표시, 실패 문구 + 다시 시도)을 쓴다.
///
/// ```dart
/// PageStateBuilder(
///   state: controller.pageState,
///   onRetry: controller.load,
///   success: (_) => ListView(...),
/// )
/// ```
class PageStateBuilder extends StatelessWidget {
  const PageStateBuilder({
    super.key,
    required this.state,
    required this.success,
    this.loading,
    this.failed,
    this.empty,
    this.noInternet,
    this.initial,
    this.onRetry,
  });

  final Rx<PageState> state;
  final WidgetBuilder success;
  final WidgetBuilder? loading;
  final WidgetBuilder? failed;
  final WidgetBuilder? empty;
  final WidgetBuilder? noInternet;
  final WidgetBuilder? initial;

  /// 기본 실패 화면의 "다시 시도" 버튼 동작
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return switch (state.value) {
        PageState.initial => initial?.call(context) ?? const SizedBox.shrink(),
        PageState.loading => loading?.call(context) ?? const Center(child: CircularProgressIndicator()),
        PageState.success => success(context),
        PageState.empty => empty?.call(context) ?? const StateMessage(title: '표시할 데이터가 없습니다'),
        PageState.noInternet => noInternet?.call(context) ??
            StateMessage(title: '인터넷 연결을 확인해 주세요', onRetry: onRetry),
        PageState.failed => failed?.call(context) ??
            StateMessage(
              title: '데이터를 가져오는데 실패했습니다',
              description: '다시 시도해 주세요',
              onRetry: onRetry,
            ),
      };
    });
  }
}

/// 빈 화면/실패 화면에 쓰는 기본 안내 위젯
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.retryText = '다시 시도',
  });

  final String title;
  final String? description;
  final VoidCallback? onRetry;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(description!, style: textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onRetry, child: Text(retryText)),
            ],
          ],
        ),
      ),
    );
  }
}
