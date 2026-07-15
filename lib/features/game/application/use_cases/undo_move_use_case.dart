import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

class UndoMoveUseCase {
  const UndoMoveUseCase();

  Result<GameSession> call({required GameSession session}) {
    if (!session.history.canUndo) {
      return Error(GenericFailure('No moves to undo'));
    }

    final newSession = session.undoLastMove();
    return Success(newSession);
  }
}