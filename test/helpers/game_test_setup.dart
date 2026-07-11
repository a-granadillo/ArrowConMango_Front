import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';

/// Builds a horizontal (rightward) arrow occupying [length] cells.
ArrowEntity horizontalArrow(
  String id, {
  int row = 0,
  int startCol = 0,
  int length = 2,
}) {
  return ArrowEntity(
    id: id,
    direction: CardinalDirection.right,
    occupiedNodes: [
      for (var c = startCol; c < startCol + length; c++)
        Grid2DNodeId(row: row, col: c),
    ],
  );
}

/// Builds a [GamePlaying] state for widget tests (empty undo history).
GamePlaying makePlaying({
  List<ArrowEntity>? arrows,
  int moveCount = 0,
  int elapsedSeconds = 0,
  int rows = 4,
  int cols = 4,
}) {
  final list = arrows ??
      [
        horizontalArrow('a1', row: 0),
        horizontalArrow('a2', row: 2),
      ];
  return GamePlaying(
    levelId: 1,
    difficulty: 'Easy',
    rows: rows,
    cols: cols,
    boardState: BoardState(arrows: list),
    moveCount: moveCount,
    history: const CommandHistory(),
    score: const Score(totalPoints: 100),
    arrowsRemaining: list.length,
    elapsedSeconds: elapsedSeconds,
    startedAtMs: 0,
  );
}
