import '../entities/hex_level.dart';
import '../entities/level_rank_entry.dart';
import 'result.dart';

/// Contract for the Modo Creativo backend calls scoped to **hexagonal**
/// levels: creating, editing, publishing and discovering community hex
/// levels, and reading a level's own ranking.
///
/// The hex sibling of [ICreativeLevelRepository] (grid levels) — same shape,
/// backed by the same `/levels` endpoints with `shape: 'hex'`. Kept as a
/// separate interface/repository rather than parameterizing
/// [ICreativeLevelRepository] because the two board shapes have entirely
/// different domain entities ([HexLevel] vs `CreativeLevel`) and wire
/// formats (axial `{q,r}` vs `{row,col}`).
abstract class IHexCreativeLevelRepository {
  /// Creates a new unpublished draft, authored by the current player.
  Future<Result<HexLevel>> createLevel(HexLevel draft);

  /// Edits an existing unpublished draft the current player owns.
  Future<Result<HexLevel>> updateLevel(HexLevel draft);

  /// Publishes a draft the current player owns. Irreversible.
  Future<Result<HexLevel>> publishLevel(String levelId);

  /// Published community hex levels, most recently published first.
  Future<Result<List<HexLevel>>> getCommunityLevels({int? top});

  /// Every hex level (draft or published) authored by the current player.
  Future<Result<List<HexLevel>>> getMyLevels();

  /// Top scores for a single level's own ranking.
  Future<Result<List<LevelRankEntry>>> getLevelRanking(
    String levelId, {
    int? top,
  });

  /// Submits a completed run's score against [levelId]'s own ranking.
  Future<Result<void>> submitScore({
    required String levelId,
    required int moves,
    required int elapsedSeconds,
  });
}
