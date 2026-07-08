import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/move_command.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameState', () {
    BoardState dummyBoardState() {
      return BoardState(
        arrows: [
          const ArrowEntity(
            id: 'arrow_1',
            direction: CardinalDirection.right,
            occupiedNodes: [
              Grid2DNodeId(row: 0, col: 0),
              Grid2DNodeId(row: 0, col: 1),
            ],
          ),
        ],
      );
    }

    CommandHistory nonEmptyHistory() {
      final board = dummyBoardState();
      return const CommandHistory().push(
        ArrowExitCommand(
          exitedArrow: board.arrows.first,
          previousState: board,
        ),
      );
    }

    const dummyScore = Score(moves: 10, timeElapsed: 30, totalPoints: 2500);

    test('GameInitial instances are equal', () {
      expect(const GameInitial(), equals(const GameInitial()));
    });

    test('GameLoading instances with same levelId are equal', () {
      expect(
        const GameLoading(levelId: 1),
        equals(const GameLoading(levelId: 1)),
      );
    });

    test('GameLoading instances with different levelId are not equal', () {
      expect(
        const GameLoading(levelId: 1),
        isNot(equals(const GameLoading(levelId: 2))),
      );
    });

    test('GamePlaying instances with same values are equal', () {
      final state = GamePlaying(
        levelId: 1,
        difficulty: 'easy',
        boardState: dummyBoardState(),
        moveCount: 5,
        history: nonEmptyHistory(),
        score: dummyScore,
        arrowsRemaining: 3,
        elapsedSeconds: 20,
        startedAtMs: 1000,
      );

      expect(state, equals(state));
    });

    test('GamePlaying instances differ when any field changes', () {
      final base = GamePlaying(
        levelId: 1,
        difficulty: 'easy',
        boardState: dummyBoardState(),
        moveCount: 5,
        history: nonEmptyHistory(),
        score: dummyScore,
        arrowsRemaining: 3,
        elapsedSeconds: 20,
        startedAtMs: 1000,
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 2,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'hard',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      final differentBoard = BoardState(
        arrows: [
          const ArrowEntity(
            id: 'arrow_2',
            direction: CardinalDirection.right,
            occupiedNodes: [
              Grid2DNodeId(row: 0, col: 0),
              Grid2DNodeId(row: 0, col: 1),
            ],
          ),
        ],
      );
      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: differentBoard,
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 99,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: const CommandHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: const Score(moves: 99, timeElapsed: 30, totalPoints: 2500),
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 99,
              elapsedSeconds: 20,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 99,
              startedAtMs: 1000,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            GamePlaying(
              levelId: 1,
              difficulty: 'easy',
              boardState: dummyBoardState(),
              moveCount: 5,
              history: nonEmptyHistory(),
              score: dummyScore,
              arrowsRemaining: 3,
              elapsedSeconds: 20,
              startedAtMs: 9999,
            ),
          ),
        ),
      );
    });

    test('GameVictory instances with same values are equal', () {
      expect(
        const GameVictory(
          levelId: 1,
          score: dummyScore,
          moveCount: 10,
          elapsedSeconds: 30,
        ),
        equals(
          const GameVictory(
            levelId: 1,
            score: dummyScore,
            moveCount: 10,
            elapsedSeconds: 30,
          ),
        ),
      );
    });

    test('GameVictory instances with different values are not equal', () {
      expect(
        const GameVictory(
          levelId: 1,
          score: dummyScore,
          moveCount: 10,
          elapsedSeconds: 30,
        ),
        isNot(
          equals(
            const GameVictory(
              levelId: 2,
              score: dummyScore,
              moveCount: 10,
              elapsedSeconds: 30,
            ),
          ),
        ),
      );
    });

    test('GameDefeat instances with same values are equal', () {
      expect(
        const GameDefeat(
          levelId: 1,
          reason: DefeatReason.noMovesAvailable,
          moveCount: 10,
          elapsedSeconds: 30,
        ),
        equals(
          const GameDefeat(
            levelId: 1,
            reason: DefeatReason.noMovesAvailable,
            moveCount: 10,
            elapsedSeconds: 30,
          ),
        ),
      );
    });

    test('GameDefeat instances differ when any field changes', () {
      const base = GameDefeat(
        levelId: 1,
        reason: DefeatReason.noMovesAvailable,
        moveCount: 10,
        elapsedSeconds: 30,
      );

      expect(
        base,
        isNot(
          equals(
            const GameDefeat(
              levelId: 2,
              reason: DefeatReason.noMovesAvailable,
              moveCount: 10,
              elapsedSeconds: 30,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            const GameDefeat(
              levelId: 1,
              reason: DefeatReason.timeExpired,
              moveCount: 10,
              elapsedSeconds: 30,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            const GameDefeat(
              levelId: 1,
              reason: DefeatReason.noMovesAvailable,
              moveCount: 99,
              elapsedSeconds: 30,
            ),
          ),
        ),
      );

      expect(
        base,
        isNot(
          equals(
            const GameDefeat(
              levelId: 1,
              reason: DefeatReason.noMovesAvailable,
              moveCount: 10,
              elapsedSeconds: 99,
            ),
          ),
        ),
      );
    });

    test('GameError instances with same values are equal', () {
      expect(
        const GameError(message: 'oops', levelId: 1),
        equals(const GameError(message: 'oops', levelId: 1)),
      );
    });

    test('GameError instances with different values are not equal', () {
      expect(
        const GameError(message: 'oops', levelId: 1),
        isNot(equals(const GameError(message: 'oops', levelId: 2))),
      );

      expect(
        const GameError(message: 'oops', levelId: 1),
        isNot(equals(const GameError(message: 'other', levelId: 1))),
      );
    });

    test('GameError with null levelId is equal to another with null levelId', () {
      expect(
        const GameError(message: 'oops'),
        equals(const GameError(message: 'oops')),
      );
    });
  });
}
