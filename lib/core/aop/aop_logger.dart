import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Optional hook used by tests to capture AOP log calls without touching
/// the real `dart:developer` logger.
@visibleForTesting
void Function(
  String name,
  String message, {
  Object? error,
  StackTrace? stackTrace,
})? aopLogOverride;

/// Internal debug logger shared by all AOP decorators.
///
/// Release builds are completely silent to avoid leaking information
/// or paying any runtime cost in production.
void aopLog(
  String name,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kReleaseMode) return;

  final override = aopLogOverride;
  if (override != null) {
    override(
      name,
      message,
      error: error,
      stackTrace: stackTrace,
    );
    return;
  }

  if (kIsWeb) {
    final errorDetail = error != null ? ' | Error: $error' : '';
    debugPrint('[$name] $message$errorDetail');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
    return;
  }

  developer.log(
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );
}
