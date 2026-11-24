/// GetX 기반 Flutter 앱의 기본 프레임.
///
/// `import 'package:getx_starter_kit/getx_starter_kit.dart';` 한 줄로
/// BaseView / BaseController / BaseBinding / PageState 와,
/// 함께 포함된 flutter_api_kit(네트워크 · Failure · 유틸)을 모두 쓸 수 있다.
library;

// 상태관리와 무관한 네트워크·유틸 계층 (별도 패키지)
export 'package:flutter_api_kit/flutter_api_kit.dart';

export 'src/base/base_binding.dart';
export 'src/base/base_controller.dart';
export 'src/base/base_view.dart';
export 'src/base/page_state.dart';
export 'src/widgets/gap.dart';
export 'src/widgets/page_state_builder.dart';
export 'src/widgets/scaffold_loading.dart';
