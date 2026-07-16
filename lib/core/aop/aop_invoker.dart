import 'dart:async';
import 'dart:io';

import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import 'aop_logger.dart';

/// Central helper that applies logging and optional error handling to a
/// repository call without changing its public signature.
///
/// Two entry points are provided so the type system stays sound:
///   - [invokeResult] for methods that return [Result<R>]. Caught
///     infrastructure exceptions are converted to [Error<R>].
///   - [invoke] for methods that return any other [R]. Caught exceptions
///     are logged and rethrown so programming errors are not swallowed.
abstract final class AopInvoker {
  const AopInvoker._();

  /// Helper to determine if an caught error is a known infrastructure failure
  /// (database, network, file system, or timeouts).
  static bool _isInfrastructureException(Object error) {
    return error is DioException ||
        error is HiveError ||
        error is FileSystemException ||
        error is SocketException ||
        error is TimeoutException;
  }

  /// Sync helper used for non-Future repository methods.
  static T invokeSync<T>(
    String interfaceName,
    String methodName,
    T Function() action,
  ) {
    aopLog('AOP.$interfaceName', '▶ $methodName');
    try {
      final result = action();
      aopLog('AOP.$interfaceName', '✔ $methodName');
      return result;
    } on Exception catch (e, stackTrace) {
      aopLog(
        'AOP.$interfaceName',
        '✖ $methodName',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Helper for Future-returning repository methods that are not [Result]-based.
  static Future<R> invoke<R>(
    String interfaceName,
    String methodName,
    Future<R> Function() action,
  ) async {
    aopLog('AOP.$interfaceName', '▶ $methodName');
    final stopwatch = Stopwatch()..start();

    try {
      final result = await action();
      stopwatch.stop();
      aopLog(
        'AOP.$interfaceName',
        '✔ $methodName (${stopwatch.elapsedMilliseconds}ms)',
      );
      return result;
    } on Exception catch (e, stackTrace) {
      stopwatch.stop();
      aopLog(
        'AOP.$interfaceName',
        '✖ $methodName (${stopwatch.elapsedMilliseconds}ms)',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Helper for Future-returning repository methods that produce [Result<R>].
  ///
  /// Infrastructure exceptions (Hive, Dio, file system, timeouts) are captured
  /// and translated into a domain [GenericFailure] wrapped in [Error<R>].
  ///
  /// Programming errors (like [ArgumentError] or [TypeError]) are rethrown
  /// immediately so they fail fast and are not silently swallowed.
  static Future<Result<R>> invokeResult<R>(
    String interfaceName,
    String methodName,
    Future<Result<R>> Function() action,
  ) async {
    aopLog('AOP.$interfaceName', '▶ $methodName');
    final stopwatch = Stopwatch()..start();

    try {
      final result = await action();
      stopwatch.stop();
      final status = result is Success ? 'Success' : 'Error';
      aopLog(
        'AOP.$interfaceName',
        '✔ $methodName [$status] (${stopwatch.elapsedMilliseconds}ms)',
      );
      return result;
    } on Object catch (e, stackTrace) {
      stopwatch.stop();
      aopLog(
        'AOP.$interfaceName',
        '✖ $methodName (${stopwatch.elapsedMilliseconds}ms)',
        error: e,
        stackTrace: stackTrace,
      );

      if (_isInfrastructureException(e)) {
        return Error<R>(GenericFailure(e.toString()));
      }
      rethrow;
    }
  }
}
