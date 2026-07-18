import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

import 'aop_invoker.dart';

/// AOP decorator around [IProgressRepository].
///
/// Adds centralized logging and infrastructure-exception handling while
/// keeping the public contract identical to the underlying implementation.
class AopProgressRepository implements IProgressRepository {
  const AopProgressRepository(this._delegate);

  final IProgressRepository _delegate;

  @override
  Future<Result<AppProgress>> loadProgress() => AopInvoker.invokeResult(
        'IProgressRepository',
        'loadProgress',
        _delegate.loadProgress,
      );

  @override
  Future<Result<void>> saveProgress(AppProgress progress) =>
      AopInvoker.invokeResult(
        'IProgressRepository',
        'saveProgress',
        () => _delegate.saveProgress(progress),
      );
}
