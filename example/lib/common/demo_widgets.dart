// =============================================================================
// 예제 화면 공통 위젯
//
// 여러 예제 화면에서 반복되는 UI(안내 박스, 섹션 카드, 코드 박스, 로그)를
// 컴포넌트로 묶었다. 실제 프로젝트에서도 이렇게 core/widgets 에 모아 재사용한다.
// =============================================================================
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

/// 화면 맨 위 "이 화면에서 배우는 것" 안내 박스
class DemoHeader extends StatelessWidget {
  const DemoHeader({super.key, required this.icon, required this.color, required this.points});

  final IconData icon;
  final Color color;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이 화면에서 배우는 것',
                    style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                const SizedBox(height: 6),
                for (final p in points)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text('· $p', style: const TextStyle(color: AppColors.textStrong, height: 1.4)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 둥근 사각형 안의 아이콘
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// 제목 + 설명 + 내용 + (선택) 코드 예시를 담는 카드
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, this.description, this.code, this.child});

  final String title;
  final String? description;
  final String? code;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(description!, style: const TextStyle(color: AppColors.textWeak, fontSize: 13, height: 1.4)),
            ],
            if (child != null) ...[
              const SizedBox(height: 14),
              child!,
            ],
            if (code != null) ...[
              const SizedBox(height: 14),
              CodeBox(code!),
            ],
          ],
        ),
      ),
    );
  }
}

/// 어두운 배경의 코드 예시
class CodeBox extends StatelessWidget {
  const CodeBox(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: AppColors.codeText, height: 1.5),
        ),
      ),
    );
  }
}

/// 상태를 색으로 보여주는 작은 배지
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

/// 실행 결과를 위에서부터 쌓아 보여주는 로그 카드
class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.logs, this.trailing});

  final RxList<String> logs;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return DemoSection(
      title: '실행 로그',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trailing != null) ...[trailing!, const SizedBox(height: 10)],
          Obx(() {
            if (logs.isEmpty) {
              return const Text('버튼을 눌러 보세요.', style: TextStyle(color: AppColors.textWeak));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, log) in logs.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: i == 0 ? AppColors.primary : AppColors.border)
                            .paddingOnly(top: 6, right: 10),
                        Expanded(child: Text(log)),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// 예제 화면 본문의 기본 틀: 좌우 여백 + 섹션 사이 간격
class DemoScrollBody extends StatelessWidget {
  const DemoScrollBody({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => children[i],
    );
  }
}
