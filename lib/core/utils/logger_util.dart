import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerUtil {
  static late Logger _logger;

  static void init(Logger logger) {
    _logger = logger;
  }

  static void debug(String message) {
    if (!kReleaseMode) {
      _logger.d(message);
    }
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message) {
    _logger.f(message);
  }
}