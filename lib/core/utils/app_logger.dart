import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[INFO] ${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[WARN] ${tag != null ? '[$tag] ' : ''}$message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR_DETAILS] $error');
    }
    if (stackTrace != null) {
      debugPrint('[STACK_TRACE] $stackTrace');
    }
  }
}
