import 'package:flutter/foundation.dart';

abstract final class KcLogger {
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Exception: $error');
      if (stackTrace != null) debugPrint('Stacktrace: $stackTrace');
    }
  }
}
