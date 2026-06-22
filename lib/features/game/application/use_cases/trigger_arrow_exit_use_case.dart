import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/errors/arrow_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import '../../domain/services/collision_validator.dart';


class TriggerArrowExitUseCase {
  final CollisionValidator _collisionValidator;

  const TriggerArrowExitUseCase(this._collisionValidator);

  Result<GameSession> call({
    required GameSession session,
    required String arrowId,
  }) {
    final ArrowEntity ? arrow = session.boardState.getArrowById(arrowId);

    if (arrow == null) {
      return Error(ArrowNotFoundFailure(arrowId: arrowId));
    }

    final exitCheck = _collisionValidator.checkExit(arrow, session.boardState);

    if (!exitCheck.canExit) {
      return Error(
        PathBlockedFailure(
          movingArrowId: arrowId,
          blockingArrowId: exitCheck.blockingArrowId!,
        ),
      );
    }

    try {
      final newSession = session.afterArrowExit(arrow);
      return Success(newSession);
    } on ArrowNotFoundFailure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(GenericFailure(e.toString()));
    }
  }
}