import 'package:equatable/equatable.dart';

import 'board_geometry.dart';
import 'board_state.dart';
import 'level.dart';

/// A hexagonal-board level: everything [Level] has, plus the metadata the
/// hexagonal mode's catalogue and creative-mode editor need (the
/// backend-issued string id, and — for player-authored levels — author,
/// publish state).
///
/// Kept as its own entity rather than reusing [Level] directly because
/// [Level.levelId] is an `int` (baked into HUD text and session ids) while
/// the backend's hexagonal catalogue is identified by a string id (e.g.
/// "hex-001") — mirrors how [CreativeLevel] bridges the same mismatch for
/// community levels. Unlike [CreativeLevel] (grid-only), this single entity
/// serves both the read-only catalogue (author/publish fields null) and the
/// creative-mode hexagonal editor (author/publish fields populated) —
/// mirroring how the backend's `LevelDefinition` unifies campaign, hex and
/// community levels behind one aggregate. [toPlayableLevel] bridges the
/// domain/HUD id mismatch at the point a level is actually played.
class HexLevel extends Equatable {
  const HexLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.radius,
    required this.templateBoard,
    this.timeLimitSeconds,
    this.maxMistakes,
    this.authorId,
    this.isPublished = false,
    this.publishedAt,
  });

  final String id;
  final String name;
  final String difficulty;
  final int radius;
  final BoardState templateBoard;
  final int? timeLimitSeconds;
  final int? maxMistakes;

  /// Null for the catalogue's official levels; the creator's user id for
  /// creative-mode (community) levels.
  final String? authorId;
  final bool isPublished;
  final DateTime? publishedAt;

  int get arrowCount => templateBoard.arrows.length;

  /// Builds a playable [Level] for this hexagonal level.
  ///
  /// [syntheticId] only needs to be stable for the lifetime of the play
  /// session (HUD text, undo history) — the hexagonal mode has its own
  /// cubit/screen and never routes through [GameBloc]'s campaign/endless
  /// `levelId` conventions, so it doesn't need to dodge those ranges the way
  /// [CreativeLevel.syntheticLevelId] does.
  Level toPlayableLevel({required int syntheticId}) {
    return Level(
      levelId: syntheticId,
      name: name,
      geometry: BoardGeometryHex(radius: radius),
      templateBoard: templateBoard,
      difficultyOverride: difficulty,
    );
  }

  /// A stable-for-this-session positive int derived from [id].
  int get syntheticLevelId => 600000 + (id.hashCode.abs() % 100000);

  HexLevel copyWith({
    String? id,
    String? name,
    String? difficulty,
    int? radius,
    BoardState? templateBoard,
    int? timeLimitSeconds,
    int? maxMistakes,
    String? authorId,
    bool? isPublished,
    DateTime? publishedAt,
  }) {
    return HexLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      radius: radius ?? this.radius,
      templateBoard: templateBoard ?? this.templateBoard,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      maxMistakes: maxMistakes ?? this.maxMistakes,
      authorId: authorId ?? this.authorId,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        difficulty,
        radius,
        templateBoard,
        timeLimitSeconds,
        maxMistakes,
        authorId,
        isPublished,
        publishedAt,
      ];
}
