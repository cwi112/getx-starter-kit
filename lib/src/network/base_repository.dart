import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../utils/logger_util.dart';
import 'api_client.dart';
import 'failure.dart';

/// 모든 Repository 의 공통 부모.
///
/// [safeCall] 이 HTTP 상태 확인과 예외 처리를 맡으므로, 각 Repository 는
/// "어떤 요청을 보내고 무엇으로 변환할지"만 작성하면 된다.
///
/// ```dart
/// class UserRepository extends BaseRepository {
///   Future<Either<Failure, User>> getUser(int id) => safeCall(
///         () => client.get('/users/$id'),
///         parser: (json) => User.fromJson(json),
///       );
/// }
/// ```
abstract class BaseRepository {
  ApiClient get client => ApiClient.instance;

  Future<Either<Failure, T>> safeCall<T>(
    Future<Response<dynamic>> Function() request, {
    required T Function(dynamic data) parser,
    bool Function(int? statusCode) isSuccess = _isHttpSuccess,
  }) async {
    try {
      final response = await request();

      if (!isSuccess(response.statusCode)) {
        return Left(ResponseFailure(response.statusCode));
      }

      return Right(parser(response.data));
    } on DioException catch (e, s) {
      final status = e.response?.statusCode;
      if (e.type == DioExceptionType.badResponse && status != null) {
        return Left(ResponseFailure(status));
      }
      LoggerUtil.instance.logger.w('safeCall network error', error: e, stackTrace: s);
      return Left(NetworkFailure(e));
    } catch (e, s) {
      LoggerUtil.instance.logger.e('safeCall unknown error', error: e, stackTrace: s);
      return Left(UnknownFailure(e));
    }
  }

  static bool _isHttpSuccess(int? code) => code != null && code >= 200 && code < 300;
}
