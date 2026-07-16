import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

import 'aop_invoker.dart';

/// AOP decorator around [ILevelRepository].
///
/// Adds centralized logging and infrastructure-exception handling while
/// keeping the public contract identical to the underlying implementation.
class AopLevelRepository implements ILevelRepository {
  const AopLevelRepository(this._delegate);

  final ILevelRepository _delegate;

  @override
  Future<Result<GameSession>> loadLevel(int levelId) =>
      AopInvoker.invokeResult(
        'ILevelRepository',
        'loadLevel',
        () => _delegate.loadLevel(levelId),
      );

  @override
  Future<Result<int>> getLevelCount() => AopInvoker.invokeResult(
        'ILevelRepository',
        'getLevelCount',
        _delegate.getLevelCount,
      );

  @override
  Future<Result<Level>> getLevelDefinition(int levelId) =>
      AopInvoker.invokeResult(
        'ILevelRepository',
        'getLevelDefinition',
        () => _delegate.getLevelDefinition(levelId),
      );
}
