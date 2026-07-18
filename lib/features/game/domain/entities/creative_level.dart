import 'package:equatable/equatable.dart';

import 'board_geometry.dart';
import 'board_state.dart';
import 'level.dart';

/// A community-made level: everything [Level] has, plus the metadata the
/// Modo Creativo screens need (author, publish state, the string id the
/// backend uses) that campaign levels don't carry.
///
/// Kept as its own entity rather than reusing [Level] directly because
/// [Level.levelId] is an `int` (baked into HUD text, session ids, and the
/// campaign's 1-15 catalogue) while community levels are identified by a
/// backend-issued UUID. [toPlayableLevel] bridges the two at the point a
/// level is actually played.
class CreativeLevel extends Equatable {
  const CreativeLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.templateBoard,
    required this.authorId,
    required this.isPublished,
    this.publishedAt,
    this.timeLimitSeconds,
    this.maxMistakes,
  });

  final String id;
  final String name;
  final String difficulty;
  final int rows;
  final int cols;
  final BoardState templateBoard;
  final String? authorId;
  final bool isPublished;
  final DateTime? publishedAt;
  final int? timeLimitSeconds;
  final int? maxMistakes;

  int get arrowCount => templateBoard.arrows.length;

  /// Builds a playable [Level] for this draft/published level.
  ///
  /// [syntheticId] must be a positive int outside the campaign's 1-15 range
  /// (so [Level.difficulty] doesn't misfire) and outside endless mode's
  /// negative range (so [GameBloc] doesn't treat it as endless) — stable
  /// for the lifetime of the session, not necessarily across app restarts.
  Level toPlayableLevel({required int syntheticId}) {
    return Level(
      levelId: syntheticId,
      name: name,
      geometry: BoardGeometry2D(rows: rows, cols: cols),
      templateBoard: templateBoard,
      difficultyOverride: difficulty,
    );
  }

  /// A stable-for-this-session positive int derived from [id], safely
  /// outside both the campaign range (1-15) and endless mode's negative
  /// range — see [toPlayableLevel].
  int get syntheticLevelId => 100000 + (id.hashCode.abs() % 900000);

  @override
  List<Object?> get props => [
        id,
        name,
        difficulty,
        rows,
        cols,
        templateBoard,
        authorId,
        isPublished,
        publishedAt,
        timeLimitSeconds,
        maxMistakes,
      ];
}
