import 'package:logger/logger.dart';

/// 앱 전역 Logger. 별도 초기화 없이 바로 쓸 수 있고, [init] 으로 설정을 바꿀 수 있다.
class LoggerUtil {
  LoggerUtil._();

  static final LoggerUtil instance = LoggerUtil._();

  Logger logger = Logger(printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8));

  static LoggerUtil init({Logger? logger, Level level = Level.trace}) {
    instance.logger = logger ??
        Logger(
          level: level,
          printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, lineLength: 120),
        );
    return instance;
  }
}
