import 'package:flutter/widgets.dart';

/// 세로 여백
class Height extends StatelessWidget {
  const Height(this.height, {super.key});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// 가로 여백
class Width extends StatelessWidget {
  const Width(this.width, {super.key});

  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(width: width);
}

const emptyBox = SizedBox.shrink();
