// =============================================================================
// getx_starter_kit 예제 앱 진입점
//
// 이 파일에서 배우는 것
// - 앱 시작 시 LoggerUtil, ApiClient 를 한 번만 초기화하는 방법
// - GetMaterialApp 에 라우트(AppPages)를 연결하는 방법
// =============================================================================
import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

void main() {
  // 로그 설정. 생략해도 기본 Logger 로 동작한다.
  LoggerUtil.init();

  // 모든 Repository 가 공유하는 Dio 설정. 공통 헤더(토큰, 앱 버전 등)도 여기서 넣는다.
  ApiClient.init(baseUrl: 'https://jsonplaceholder.typicode.com');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX 의 라우팅, 다이얼로그, 스낵바를 쓰려면 MaterialApp 대신 GetMaterialApp 을 쓴다.
    return GetMaterialApp(
      title: 'getx_starter_kit example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // 색·버튼·카드 스타일은 theme/app_theme.dart 에서 관리
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}
