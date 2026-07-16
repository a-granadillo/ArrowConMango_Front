import 'package:flutter_bloc/flutter_bloc.dart';

import 'aop_logger.dart';

/// Global BLoC observer that logs lifecycle events, transitions and errors.
///
/// Logging is gated behind [kReleaseMode] so release builds stay silent and
/// performant. The observer is registered once in [main.dart]:
///
/// ```dart
/// Bloc.observer = AppBlocObserver();
/// ```
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    aopLog('AOP.Bloc', 'create ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    aopLog('AOP.Bloc', 'close ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    aopLog('AOP.Bloc', 'event ${bloc.runtimeType} -> ${event.runtimeType}');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    aopLog(
      'AOP.Bloc',
      'transition ${bloc.runtimeType}: '
      '${transition.currentState.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(
    BlocBase bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    aopLog(
      'AOP.Bloc',
      'error ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
