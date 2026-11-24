import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get deviceWidth => MediaQuery.sizeOf(this).width;

  double get deviceHeight => MediaQuery.sizeOf(this).height;

  void unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  /// 버튼 하나짜리 안내 다이얼로그
  Future<void> messageDialog({required String content, String btnName = '확인'}) {
    return showDialog<void>(
      context: this,
      builder: (context) => AlertDialog(
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(btnName)),
        ],
      ),
    );
  }

  /// 예/아니오 다이얼로그. 예를 누르면 true.
  Future<bool> confirmDialog({
    required String content,
    String successText = '예',
    String failedText = '아니오',
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(failedText)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(successText)),
        ],
      ),
    );
    return result ?? false;
  }

  void toast(String msg, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: duration));
  }
}
