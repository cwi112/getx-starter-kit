/// GetX 기반 Flutter 앱의 기본 프레임.
///
/// `import 'package:app_base_getx/app_base_getx.dart';` 한 줄로
/// BaseView / BaseController / BaseBinding / 네트워크 / 공용 위젯을 모두 쓸 수 있다.
library;

export 'package:dartz/dartz.dart' show Either, Left, Right;

export 'src/base/base_binding.dart';
export 'src/base/base_controller.dart';
export 'src/base/base_view.dart';
export 'src/base/page_state.dart';
export 'src/extensions/context_extension.dart';
export 'src/network/api_client.dart';
export 'src/network/base_repository.dart';
export 'src/network/failure.dart';
export 'src/utils/logger_util.dart';
export 'src/utils/parsing_util.dart';
export 'src/widgets/gap.dart';
export 'src/widgets/page_state_builder.dart';
export 'src/widgets/scaffold_loading.dart';
