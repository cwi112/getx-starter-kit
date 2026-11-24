import 'package:dio/dio.dart';

/// API 호출 실패를 표현하는 공통 타입. [BaseRepository.safeCall] 의 Left 값이다.
sealed class Failure {
  const Failure(this.message);

  /// 사용자에게 보여줄 수 있는 메시지
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 서버가 응답했지만 HTTP 상태 코드가 실패인 경우
class ResponseFailure extends Failure {
  ResponseFailure(this.statusCode) : super(messageOf(statusCode));

  final int? statusCode;

  static String messageOf(int? statusCode) => switch (statusCode) {
        null => '알 수 없는 상태값입니다.',
        400 => '잘못된 요청입니다.',
        401 => '인증이 실패하였습니다.',
        403 => '해당 요청이 금지되었습니다.',
        404 => '요청한 자원을 찾을 수 없습니다.',
        500 => '내부 서버 오류가 발생했습니다.',
        502 => '서버가 잘못된 응답을 받았습니다.',
        503 => '서비스를 사용할 수 없습니다.',
        504 => '게이트웨이 시간이 초과되었습니다.',
        _ => '알 수 없는 오류가 발생했습니다.',
      };
}

/// 연결 실패, 타임아웃 등 Dio 단계에서 발생한 오류
class NetworkFailure extends Failure {
  NetworkFailure(this.exception) : super(messageOf(exception.type));

  final DioException exception;

  bool get isConnectionError => exception.type == DioExceptionType.connectionError;

  static String messageOf(DioExceptionType type) => switch (type) {
        DioExceptionType.connectionError => '인터넷 연결을 확인해 주세요.',
        DioExceptionType.receiveTimeout => '서버로부터의 응답 시간이 초과되었습니다.',
        DioExceptionType.connectionTimeout => '서버와의 연결 시간이 초과되었습니다.',
        DioExceptionType.sendTimeout => '요청을 보내는데 시간이 초과되었습니다.',
        DioExceptionType.badCertificate => '잘못된 인증서가 감지되었습니다.',
        DioExceptionType.badResponse => '잘못된 응답이 수신되었습니다.',
        DioExceptionType.cancel => '요청이 취소되었습니다.',
        _ => '알 수 없는 오류가 발생했습니다.',
      };
}

/// 응답 파싱 실패 등 그 밖의 예외
class UnknownFailure extends Failure {
  const UnknownFailure(this.error, [super.message = '알 수 없는 오류가 발생했습니다.']);

  final Object error;
}
