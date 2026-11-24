/// 화면(또는 화면 일부)의 비동기 상태.
///
/// [BaseController]의 `Rx<PageState>` 와 [PageStateBuilder] 가 함께 사용한다.
enum PageState {
  /// 아직 아무 작업도 하지 않은 상태
  initial,

  /// 로딩 중
  loading,

  /// 성공
  success,

  /// 실패
  failed,

  /// 성공했지만 표시할 데이터가 없음
  empty,

  /// 네트워크 연결 없음
  noInternet;

  bool get isInitial => this == PageState.initial;
  bool get isLoading => this == PageState.loading;
  bool get isSuccess => this == PageState.success;
  bool get isFailed => this == PageState.failed;
  bool get isEmpty => this == PageState.empty;
  bool get isNoInternet => this == PageState.noInternet;
}
