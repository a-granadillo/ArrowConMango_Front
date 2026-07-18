import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:arrowconmango_front/features/player/domain/i_player_repository.dart';

import 'aop_invoker.dart';

/// AOP decorator around [IPlayerRepository].
///
/// Adds centralized logging and safely propagates infrastructure exceptions
/// (e.g. local storage failures) so the UI layer still receives the same
/// failure surface it would without AOP.
class AopPlayerRepository implements IPlayerRepository {
  const AopPlayerRepository(this._delegate);

  final IPlayerRepository _delegate;

  @override
  GuestPlayer getOrCreate() => AopInvoker.invokeSync(
        'IPlayerRepository',
        'getOrCreate',
        _delegate.getOrCreate,
      );

  @override
  Future<void> saveDisplayName(String displayName) => AopInvoker.invoke(
        'IPlayerRepository',
        'saveDisplayName',
        () => _delegate.saveDisplayName(displayName),
      );
}
