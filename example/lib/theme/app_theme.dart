// =============================================================================
// 예제 앱 테마
//
// 색·모서리·버튼 모양을 여기 한곳에서 정하면 모든 화면에 자동으로 적용된다.
// 화면 코드에서는 색을 직접 쓰기보다 Theme.of(context).colorScheme 을 쓰는 것이 좋다.
// =============================================================================
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const background = Color(0xFFF4F5FA);
  static const surface = Colors.white;
  static const border = Color(0xFFE6E8F0);
  static const textStrong = Color(0xFF1F2937);
  static const textWeak = Color(0xFF6B7280);
  static const codeBackground = Color(0xFF1E1E2E);
  static const codeText = Color(0xFFE2E4F3);

  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);

  // 메뉴별 포인트 색
  static const indigo = Color(0xFF4F46E5);
  static const sky = Color(0xFF0284C7);
  static const teal = Color(0xFF0D9488);
  static const rose = Color(0xFFE11D48);
  static const amber = Color(0xFFD97706);
  static const violet = Color(0xFF7C3AED);
  static const slate = Color(0xFF334155);
}

abstract final class AppTheme {
  static const radius = 16.0;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    );

    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textStrong,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textStrong),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48), shape: rounded),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), shape: rounded),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: AppColors.surface),
    );
  }
}
