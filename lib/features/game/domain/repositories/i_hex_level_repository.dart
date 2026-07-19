import '../entities/hex_level.dart';
import 'result.dart';

/// Contract for loading the hexagonal-mode level catalogue.
///
/// Unlike [ILevelRepository] (the campaign catalogue), this has no Hive
/// persistence — the hexagonal board's axial coordinates aren't representable
/// by the existing 2D-only Hive models ([NodeModel]/[ArrowTrajectory]), so
/// implementations fall back to an in-memory generated catalogue
/// ([HexLevels]) when the backend is unreachable, mirroring how the Cube 3D
/// mode generates its levels at runtime instead of persisting them.
abstract class IHexLevelRepository {
  /// Every hexagonal level available right now (remote catalogue when
  /// reachable, otherwise the local generated fallback), in progression
  /// order (easiest first).
  Future<Result<List<HexLevel>>> getLevels();

  /// Submits a completed run's score against [levelId]'s hexagonal-mode
  /// leaderboard entry. Best-effort — see [SubmitScoreUseCase].
  Future<Result<void>> submitScore({
    required String levelId,
    required int moves,
    required int elapsedSeconds,
  });
}
