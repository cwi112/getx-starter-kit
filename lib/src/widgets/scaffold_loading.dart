import 'package:flutter/material.dart';

/// 화면 전체를 반투명하게 덮는 로딩 오버레이. [BaseView] 의 기본 로딩 화면.
class ScaffoldLoading extends StatelessWidget {
  const ScaffoldLoading({super.key, this.loadingText = '', this.barrierColor});

  final String loadingText;
  final Color? barrierColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AbsorbPointer(
        child: ColoredBox(
          color: barrierColor ?? Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loadingText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        loadingText,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
