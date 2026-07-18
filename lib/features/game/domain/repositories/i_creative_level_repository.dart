import '../entities/creative_level.dart';
import '../entities/level_rank_entry.dart';
import 'result.dart';

/// Contract for the Modo Creativo backend calls: creating, editing,
/// publishing and discovering community levels, and reading a level's own
/// ranking.
///
/// Unlike [ILevelRepository] (the campaign catalogue), this has no local
/// persistence — community levels are remote-only, cached for the current
/// session at most (see the community-levels ADR: "no van a Hive").
abstract class ICreativeLevelRepository {
  /// Creates a new unpublished draft, authored by the current player.
  Future<Result<CreativeLevel>> createLevel(CreativeLevel draft);

  /// Edits an existing unpublished draft the current player owns.
  Future<Result<CreativeLevel>> updateLevel(CreativeLevel draft);

  /// Publishes a draft the current player owns. Irreversible.
  Future<Result<CreativeLevel>> publishLevel(String levelId);

  /// Published community levels, most recently published first.
  Future<Result<List<CreativeLevel>>> getCommunityLevels({int? top});

  /// Every level (draft or published) authored by the current player.
  Future<Result<List<CreativeLevel>>> getMyLevels();

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
