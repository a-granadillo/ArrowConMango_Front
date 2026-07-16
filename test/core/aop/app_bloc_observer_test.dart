import 'package:arrowconmango_front/core/aop/aop_logger.dart';
import 'package:arrowconmango_front/core/aop/app_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _TestBloc extends Mock implements Bloc<int, String> {}

void main() {
  group('AppBlocObserver', () {
    late List<String> logs;
    late BlocObserver originalObserver;

    setUp(() {
      originalObserver = Bloc.observer;
      logs = [];
      aopLogOverride = (
        String name,
        String message, {
        Object? error,
        StackTrace? stackTrace,
      }) {
        if (error != null) {
          logs.add('$name: $message [error=$error]');
        } else {
          logs.add('$name: $message');
        }
      };
      Bloc.observer = AppBlocObserver();
    });

    tearDown(() {
      aopLogOverride = null;
      Bloc.observer = originalObserver;
    });

    test('logs create, event, transition and close', () async {
      final bloc = _TestBloc();
      final observer = Bloc.observer as AppBlocObserver;

      observer.onCreate(bloc);
      observer.onEvent(bloc, 1);
      observer.onTransition(
        bloc,
        const Transition(
          currentState: 'initial',
          event: 1,
          nextState: 'state-1',
        ),
      );
      observer.onClose(bloc);

      final logText = logs.join('\n');
      expect(logText, contains('create _TestBloc'));
      expect(logText, contains('event _TestBloc -> int'));
      expect(logText, contains('transition _TestBloc: String -> String'));
      expect(logText, contains('close _TestBloc'));
    });

    test('logs errors without swallowing them', () {
      final bloc = _TestBloc();
      final observer = Bloc.observer as AppBlocObserver;
      final error = Exception('expected error');
      final stackTrace = StackTrace.current;

      observer.onError(bloc, error, stackTrace);

      final logText = logs.join('\n');
      expect(logText, contains('error _TestBloc'));
      expect(logText, contains('expected error'));
    });
  });
}
