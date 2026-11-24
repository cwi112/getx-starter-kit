import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../utils/logger_util.dart';
import 'page_state.dart';

/// 모든 화면 컨트롤러(ViewModel)의 공통 부모.
///
/// - [scaffoldLoadingState] 가 [PageState.loading] 이면 [BaseView] 가
///   화면 전체를 덮는 로딩 오버레이를 띄운다.
/// - [runWithLoading] 으로 API 호출 등을 감싸면 로딩 표시/해제를 자동으로 처리한다.
abstract class BaseController extends GetxController {
  Logger get logger => LoggerUtil.instance.logger;

  /// 화면 전체 로딩 오버레이 상태
  final Rx<PageState> scaffoldLoadingState = PageState.initial.obs;

  /// 로딩 오버레이에 함께 표시할 문구 (비어 있으면 표시하지 않음)
  final RxString loadingText = ''.obs;

  bool get isScaffoldLoading => scaffoldLoadingState.value.isLoading;

  /// [state] 를 [nextState] 로 변경한다.
  void setState(Rx<PageState> state, PageState nextState) => state.value = nextState;

  void showLoading({String text = ''}) {
    loadingText.value = text;
    setState(scaffoldLoadingState, PageState.loading);
  }

  void hideLoading({PageState result = PageState.success}) {
    loadingText.value = '';
    setState(scaffoldLoadingState, result);
  }

  /// [task] 실행 동안 화면 전체 로딩을 표시한다.
  ///
  /// 예외가 발생하면 로그를 남기고 `null` 을 반환하며, 로딩 상태는
  /// [PageState.failed] 로 끝난다. 이미 로딩 중이면 중복 실행하지 않는다.
  Future<T?> runWithLoading<T>(
    Future<T> Function() task, {
    String text = '',
  }) async {
    if (isScaffoldLoading) return null;

    showLoading(text: text);
    try {
      final result = await task();
      hideLoading();
      return result;
    } catch (e, s) {
      logger.e('runWithLoading failed', error: e, stackTrace: s);
      hideLoading(result: PageState.failed);
      return null;
    }
  }
}

/// 기존 프로젝트(`*_view_model.dart`) 명명 규칙과의 호환용 별칭.
typedef BaseViewModel = BaseController;
