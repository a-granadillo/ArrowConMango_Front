import '../entities/game_session.dart';
import '../entities/level.dart';
import 'result.dart';

/// Contract for loading and querying level definitions.
///
/// Implementations live in Layer 4 (data/) and may read from
/// JSON bundles, a remote API, or a local database.
///
/// The domain layer depends only on this interface (DIP).
abstract class ILevelRepository {
  /// Loads a level by its ID and returns a ready-to-play [GameSession].
  ///
  /// Returns [Error] with a domain [Failure] if the level does not exist
  /// or the data source is unavailable.
  Future<Result<GameSession>> loadLevel(int levelId);

  /// Returns the total number of levels available.
  Future<Result<int>> getLevelCount();

  /// Returns the [Level] definition (template board) without starting a session.
  Future<Result<Level>> getLevelDefinition(int levelId);
}
