import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/move_command.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/mappers/game_state_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper factories used across all groups.
  BoardState dummyBoardState({String arrowId = 'arrow_1'}) {
    return BoardState(
      arrows: [
        ArrowEntity(
          id: arrowId,
          direction: CardinalDirection.right,
          occupiedNodes: const [
            Grid2DNodeId(row: 0, col: 0),
            Grid2DNodeId(row: 0, col: 1),
          ],
        ),
      ],
    );
  }

  const dummyScore = Score(moves: 5, timeElapsed: 10, totalPoints: 1200);

  GameSession dummySession({
    BoardState? boardState,
    CommandHistory? history,
    int moveCount = 7,
    int startedAtMs = 10_000,
  }) {
    return GameSession(
      sessionId: 'session-1',
      boardState: boardState ?? dummyBoardState(),
      history: history ?? const CommandHistory(),
      moveCount: moveCount,
      startedAtMs: startedAtMs,
    );
  }

  Level dummyLevel({int levelId = 3, BoardState? templateBoard}) {
    return Level(
      levelId: levelId,
      templateBoard: templateBoard ?? dummyBoardState(),
    );
  }

  group('GameStateMapper.mapToPlayingState', () {
    test(
      'should map session, level, score and elapsedSeconds correctly',
      () {
        // Arrange
        final session = dummySession(startedAtMs: 10_000);
        final level = dummyLevel(levelId: 3);
        const nowMs = 25_000;

        // Act
        final result = GameStateMapper.mapToPlayingState(
          session: session,
          level: level,
          score: dummyScore,
          nowMs: nowMs,
        );

        // Assert
        expect(result, isA<GamePlaying>());
        expect(result.levelId, equals(3));
        expect(result.difficulty, equals('Easy'));
        expect(result.boardState, equals(session.boardState));
        expect(result.moveCount, equals(7));
        expect(result.canUndo, isFalse);
        expect(result.score, equals(dummyScore));
        expect(result.arrowsRemaining, equals(1));
        expect(result.elapsedSeconds, equals(15));
        expect(result.startedAtMs, equals(10_000));
      },
    );

    test(
      'should reflect canUndo true when history is not empty',
      () {
        // Arrange
        final previousBoard = dummyBoardState();
        final exitedArrow = previousBoard.arrows.first;
        final history = const CommandHistory().push(
          ArrowExitCommand(
            exitedArrow: exitedArrow,
            previousState: previousBoard,
          ),
        );
        final session = dummySession(history: history);
        final level = dummyLevel();

        // Act
        final result = GameStateMapper.mapToPlayingState(
          session: session,
          level: level,
          score: dummyScore,
          nowMs: 20_000,
        );

        // Assert
        expect(result.canUndo, isTrue);
      },
    );

    test(
      'should protect against clock skew returning elapsedSeconds = 0',
      () {
        // Arrange
        final session = dummySession(startedAtMs: 10_000);
        final level = dummyLevel();
        const nowMs = 5_000; // before startedAtMs

        // Act
        final result = GameStateMapper.mapToPlayingState(
          session: session,
          level: level,
          score: dummyScore,
          nowMs: nowMs,
        );

        // Assert
        expect(result.elapsedSeconds, equals(0));
      },
    );
  });

  group('GameStateMapper.mapToVictoryState', () {
    test(
      'should map session, level, score and elapsedSeconds correctly',
      () {
        // Arrange
        final session = dummySession(
          boardState: BoardState(arrows: const []),
          moveCount: 12,
          startedAtMs: 5_000,
        );
        final level = dummyLevel(levelId: 7);
        const score = Score(moves: 12, timeElapsed: 8, totalPoints: 3000);
        const nowMs = 18_000;

        // Act
        final result = GameStateMapper.mapToVictoryState(
          session: session,
          level: level,
          score: score,
          nowMs: nowMs,
        );

        // Assert
        expect(result, isA<GameVictory>());
        expect(result.levelId, equals(7));
        expect(result.score, equals(score));
        expect(result.moveCount, equals(12));
        expect(result.elapsedSeconds, equals(13));
      },
    );

    test(
      'should protect against clock skew returning elapsedSeconds = 0',
      () {
        // Arrange
        final session = dummySession(
          boardState: BoardState(arrows: const []),
          startedAtMs: 10_000,
        );
        final level = dummyLevel();
        const nowMs = 2_000; // before startedAtMs

        // Act
        final result = GameStateMapper.mapToVictoryState(
          session: session,
          level: level,
          score: dummyScore,
          nowMs: nowMs,
        );

        // Assert
        expect(result.elapsedSeconds, equals(0));
      },
    );
  });

  group('GameStateMapper.mapToDefeatState', () {
    test(
      'should map session, level, reason and elapsedSeconds correctly',
      () {
        // Arrange
        final session = dummySession(
          moveCount: 20,
          startedAtMs: 0,
        );
        final level = dummyLevel(levelId: 11);
        const reason = DefeatReason.timeExpired;
        const nowMs = 60_000;

        // Act
        final result = GameStateMapper.mapToDefeatState(
          session: session,
          level: level,
          reason: reason,
          nowMs: nowMs,
        );

        // Assert
        expect(result, isA<GameDefeat>());
        expect(result.levelId, equals(11));
        expect(result.reason, equals(DefeatReason.timeExpired));
        expect(result.moveCount, equals(20));
        expect(result.elapsedSeconds, equals(60));
      },
    );

    test(
      'should protect against clock skew returning elapsedSeconds = 0',
      () {
        // Arrange
        final session = dummySession(startedAtMs: 10_000);
        final level = dummyLevel();
        const reason = DefeatReason.noMovesAvailable;
        const nowMs = 1_000; // before startedAtMs

        // Act
        final result = GameStateMapper.mapToDefeatState(
          session: session,
          level: level,
          reason: reason,
          nowMs: nowMs,
        );

        // Assert
        expect(result.elapsedSeconds, equals(0));
      },
    );
  });
}
