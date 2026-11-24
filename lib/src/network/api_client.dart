import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// 앱 전역에서 하나만 쓰는 Dio 래퍼.
///
/// ```dart
/// ApiClient.init(baseUrl: 'https://api.example.com', headers: {'X-APP': 'demo'});
/// final res = await ApiClient.instance.post('/login', data: body);
/// ```
class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;

  static ApiClient? _instance;

  static ApiClient get instance {
    final client = _instance;
    if (client == null) {
      throw StateError('ApiClient.init() 을 먼저 호출해 주세요.');
    }
    return client;
  }

  static bool get isInitialized => _instance != null;

  /// 앱 시작 시 한 번 호출한다. 다시 호출하면 설정을 교체한다.
  static ApiClient init({
    required String baseUrl,
    Map<String, dynamic>? headers,
    Duration timeout = const Duration(seconds: 10),
    bool enableLog = true,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
      ),
    );

    dio.interceptors.addAll(interceptors);
    if (enableLog) {
      dio.interceptors.add(
        PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true),
      );
    }

    return _instance = ApiClient._(dio);
  }

  /// 테스트에서 가짜 Dio 를 주입할 때 사용한다.
  static void setForTest(Dio dio) => _instance = ApiClient._(dio);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query, Options? options}) =>
      dio.get<T>(path, queryParameters: query, options: options);

  Future<Response<T>> post<T>(String path, {Object? data, Options? options}) =>
      dio.post<T>(path, data: data, options: options);

  Future<Response<T>> put<T>(String path, {Object? data, Options? options}) =>
      dio.put<T>(path, data: data, options: options);

  Future<Response<T>> delete<T>(String path, {Object? data, Options? options}) =>
      dio.delete<T>(path, data: data, options: options);
}
