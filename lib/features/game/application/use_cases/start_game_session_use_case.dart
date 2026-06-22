
import 'package:arrowconmango_front/features/game/domain/errors/failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/game_session.dart';

class StartGameSessionUseCase {
  const StartGameSessionUseCase();

  Result<GameSession> call({
    required Level level,
    required String sessionId,
    required int startedAtMs,
  }) {
    try {
      final session = level.startSession(
        sessionId: sessionId,
        startedAtMs: startedAtMs,
      );
      return Success(session);
    } catch (e) {
      return Error(GenericFailure('Failed to start session: ${e.toString()}'));
    }
  }
}