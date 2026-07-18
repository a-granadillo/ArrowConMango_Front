import 'package:equatable/equatable.dart';

import 'board_geometry.dart';
import 'board_state.dart';
import 'level.dart';

/// A hexagonal-board level: everything [Level] has, plus the metadata the
/// hexagonal mode's catalogue needs (the backend-issued string id, when the
/// level came from the remote catalogue rather than the local generator).
///
/// Kept as its own entity rather than reusing [Level] directly because
/// [Level.levelId] is an `int` (baked into HUD text and session ids) while
/// the backend's hexagonal catalogue is identified by a string id (e.g.
/// "hex-001") — mirrors how [CreativeLevel] bridges the same mismatch for
/// community levels. [toPlayableLevel] bridges the two at the point a level
/// is actually played.
class HexLevel extends Equatable {
  const HexLevel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.radius,
    required this.templateBoard,
    this.timeLimitSeconds,
  });

  final String id;
  final String name;
  final String difficulty;
  final int radius;
  final BoardState templateBoard;
  final int? timeLimitSeconds;

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

  @override
  List<Object?> get props => [
        id,
        name,
        difficulty,
        radius,
        templateBoard,
        timeLimitSeconds,
      ];
}
