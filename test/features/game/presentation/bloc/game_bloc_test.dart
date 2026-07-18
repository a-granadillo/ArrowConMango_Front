import 'package:arrowconmango_front/features/game/application/dtos/game_evaluation.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/calculate_score_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/evaluate_game_state_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/load_level_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/start_game_session_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/undo_move_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/command_history.dart';
import 'package:arrowconmango_front/features/game/domain/entities/game_session.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/move_command.dart';
import 'package:arrowconmango_front/features/game/domain/entities/score.dart';
import 'package:arrowconmango_front/features/game/domain/entities/exit_check_result.dart';
import 'package:arrowconmango_front/features/game/domain/errors/arrow_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/path_blocked_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/arrow_collision_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Manual fakes for the domain use cases used by [GameBloc].
// ---------------------------------------------------------------------------

class FakeLoadLevelUseCase implements LoadLevelUseCase {
  Result<Level>? result;
  int? calledLevelId;

  @override
  Future<Result<Level>> call({required int levelId}) async {
    calledLevelId = levelId;
    final configured = result;
    if (configured == null) {
      throw StateError('Configure FakeLoadLevelUseCase.result in Arrange');
    }
    return configured;
  }
}

class FakeStartGameSessionUseCase implements StartGameSessionUseCase {
  Result<GameSession>? result;
  Level? calledLevel;
  String? calledSessionId;
  int? calledStartedAtMs;

  @override
  Result<GameSession> call({
    required Level level,
    required String sessionId,
    required int startedAtMs,
  }) {
    calledLevel = level;
    calledSessionId = sessionId;
    calledStartedAtMs = startedAtMs;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeStartGameSessionUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

class FakeEvaluateGameStateUseCase implements EvaluateGameStateUseCase {
  GameEvaluation? result;
  GameSession? calledSession;
  int? calledNowMs;

  @override
  GameEvaluation call({required GameSession session, required int nowMs}) {
    calledSession = session;
    calledNowMs = nowMs;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeEvaluateGameStateUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

class FakeTriggerArrowExitUseCase implements TriggerArrowExitUseCase {
  Result<GameSession>? result;
  GameSession? calledSession;
  String? calledArrowId;

  @override
  Result<GameSession> call({
    required GameSession session,
    required String arrowId,
  }) {
    calledSession = session;
    calledArrowId = arrowId;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeTriggerArrowExitUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

class FakeCalculateScoreUseCase implements CalculateScoreUseCase {
  Result<Score>? result;
  int? calledMoves;
  int? calledElapsedSeconds;

  @override
  Result<Score> call({required int moves, required int elapsedSeconds, int mistakes = 0}) {
    calledMoves = moves;
    calledElapsedSeconds = elapsedSeconds;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeCalculateScoreUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

class FakeUnlockNextLevelUseCase implements UnlockNextLevelUseCase {
  Result<AppProgress>? result;
  int? calledCurrentLevelId;

  @override
  Future<Result<AppProgress>> call({required int currentLevelId}) async {
    calledCurrentLevelId = currentLevelId;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeUnlockNextLevelUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

class FakeCollisionValidator implements CollisionValidator {
  bool allowExit = true;

  @override
  ExitCheckResult checkExit(arrow, board) {
    return ExitCheckResult(
      canExit: allowExit,
      blockingArrowId: allowExit ? null : 'arrow_blocker',
      clearPath: const [],
    );
  }

  @override
  bool canSlide(arrow, board, steps) => true;
}

class FakeUndoMoveUseCase implements UndoMoveUseCase {
  Result<GameSession>? result;
  GameSession? calledSession;

  @override
  Result<GameSession> call({required GameSession session}) {
    calledSession = session;
    final configured = result;
    if (configured == null) {
      throw StateError('Configure FakeUndoMoveUseCase.result in Arrange');
    }
    return configured;
  }
}

void main() {
  const clockValue = 1000;

  BoardState singleArrowBoard({String arrowId = 'arrow_1'}) {
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

  const initialScore = Score();
  const evalScore = Score(moves: 1, timeElapsed: 5, totalPoints: 100);
  const finalScore = Score(moves: 1, timeElapsed: 5, totalPoints: 1000);

  late FakeLoadLevelUseCase fakeLoadLevel;
  late FakeStartGameSessionUseCase fakeStartSession;
  late FakeEvaluateGameStateUseCase fakeEvaluateState;
  late FakeTriggerArrowExitUseCase fakeTriggerExit;
  late FakeCalculateScoreUseCase fakeCalculateScore;
  late FakeUnlockNextLevelUseCase fakeUnlockNextLevel;
  late FakeCollisionValidator fakeCollisionValidator;
  late FakeUndoMoveUseCase fakeUndoMove;

  setUp(() {
    fakeLoadLevel = FakeLoadLevelUseCase();
    fakeStartSession = FakeStartGameSessionUseCase();
    fakeEvaluateState = FakeEvaluateGameStateUseCase();
    fakeTriggerExit = FakeTriggerArrowExitUseCase();
    fakeCalculateScore = FakeCalculateScoreUseCase();
    fakeUnlockNextLevel = FakeUnlockNextLevelUseCase();
    fakeCollisionValidator = FakeCollisionValidator();
    fakeUndoMove = FakeUndoMoveUseCase();
  });

  GameBloc buildBloc() {
    return GameBloc(
      loadLevelUseCase: fakeLoadLevel,
      startGameSessionUseCase: fakeStartSession,
      evaluateGameStateUseCase: fakeEvaluateState,
      triggerArrowExitUseCase: fakeTriggerExit,
      undoMoveUseCase: fakeUndoMove,
      calculateScoreUseCase: fakeCalculateScore,
      unlockNextLevelUseCase: fakeUnlockNextLevel,
      collisionValidator: fakeCollisionValidator,
      clock: () => clockValue,
    );
  }

  group('LoadLevel', () {
    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GamePlaying] when LoadLevel is successful',
      // Arrange
      setUp: () {
        final level = Level(
          levelId: 1,
          geometry: const BoardGeometry2D(rows: 7, cols: 7),
          templateBoard: singleArrowBoard(),
        );
        final session = GameSession(
          sessionId: 'session-1',
          boardState: singleArrowBoard(),
          startedAtMs: clockValue,
        );

        fakeLoadLevel.result = Success(level);
        fakeStartSession.result = Success(session);
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const LoadLevel(levelId: 1)),
      // Assert
      expect: () => [
        const GameLoading(levelId: 1),
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          rows: 7,
          cols: 7,
          boardState: singleArrowBoard(),
          moveCount: 0,
          history: const CommandHistory(),
          score: initialScore,
          arrowsRemaining: 1,
          elapsedSeconds: 0,
          startedAtMs: clockValue,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GameError] when GetLevelDefinition fails',
      // Arrange
      setUp: () {
        fakeLoadLevel.result = Error<Level>(
          const GenericFailure('Level not found'),
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const LoadLevel(levelId: 999)),
      // Assert
      expect: () => [
        const GameLoading(levelId: 999),
        const GameError(message: 'Level not found', levelId: 999),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GameError] when StartGameSession fails',
      // Arrange
      setUp: () {
        final level = Level(
          levelId: 1,
          geometry: const BoardGeometry2D(rows: 7, cols: 7),
          templateBoard: singleArrowBoard(),
        );
        fakeLoadLevel.result = Success(level);
        fakeStartSession.result = Error<GameSession>(
          const GenericFailure('Failed to start'),
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const LoadLevel(levelId: 1)),
      // Assert
      expect: () => [
        const GameLoading(levelId: 1),
        const GameError(message: 'Failed to start', levelId: 1),
      ],
    );
  });

  group('TriggerArrowExit', () {
    GamePlaying playingSeed() {
      return GamePlaying(
        levelId: 1,
        difficulty: 'Easy',
        boardState: singleArrowBoard(),
        moveCount: 0,
        history: const CommandHistory(),
        score: initialScore,
        arrowsRemaining: 1,
        elapsedSeconds: 0,
        startedAtMs: clockValue,
      );
    }

    GameSession sessionAfterExit() {
      final previousBoard = singleArrowBoard();
      final exitedArrow = previousBoard.arrows.first;
      return GameSession(
        sessionId: 'session-1',
        boardState: BoardState(arrows: const []),
        history: const CommandHistory().push(
          ArrowExitCommand(
            exitedArrow: exitedArrow,
            previousState: previousBoard,
          ),
        ),
        moveCount: 1,
        startedAtMs: clockValue,
      );
    }

    blocTest<GameBloc, GameState>(
      'should emit updated GamePlaying when arrow exits and game continues',
      // Arrange
      setUp: () {
        fakeTriggerExit.result = Success(sessionAfterExit());
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: evalScore,
          moveCount: 1,
          elapsedSeconds: 5,
          arrowsRemaining: 0,
        );
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      // Assert
      expect: () => [
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          boardState: BoardState(arrows: const []),
          moveCount: 1,
          history: sessionAfterExit().history,
          score: evalScore,
          arrowsRemaining: 0,
          elapsedSeconds: 5,
          startedAtMs: clockValue,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GamePlaying, GameVictory] when the last arrow exits',
      // Arrange
      setUp: () {
        fakeTriggerExit.result = Success(sessionAfterExit());
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.victory,
          score: evalScore,
          moveCount: 1,
          elapsedSeconds: 5,
          arrowsRemaining: 0,
        );
        fakeCalculateScore.result = const Success(finalScore);
        fakeUnlockNextLevel.result = const Success<AppProgress>(AppProgress());
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      wait: const Duration(milliseconds: 550),
      // Assert
      expect: () => [
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          boardState: BoardState(arrows: const []),
          moveCount: 1,
          history: sessionAfterExit().history,
          score: evalScore,
          arrowsRemaining: 0,
          elapsedSeconds: 5,
          startedAtMs: clockValue,
        ),
        const GameVictory(
          levelId: 1,
          score: finalScore,
          moveCount: 1,
          elapsedSeconds: 5,
        ),
      ],
      verify: (bloc) {
        expect(fakeCalculateScore.calledMoves, equals(1));
        expect(fakeCalculateScore.calledElapsedSeconds, equals(5));
        expect(fakeUnlockNextLevel.calledCurrentLevelId, equals(1));
      },
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameDefeat] when no arrows can exit after a move',
      // Arrange
      setUp: () {
        fakeCollisionValidator.allowExit = false;
        fakeTriggerExit.result = Success(
          GameSession(
            sessionId: 'session-1',
            boardState: singleArrowBoard(),
            history: const CommandHistory().push(
              ArrowExitCommand(
                exitedArrow: singleArrowBoard().arrows.first,
                previousState: BoardState(arrows: const []),
              ),
            ),
            moveCount: 1,
            startedAtMs: clockValue,
          ),
        );
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: evalScore,
          moveCount: 1,
          elapsedSeconds: 5,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      // Assert
      expect: () => [
        const GameDefeat(
          levelId: 1,
          reason: DefeatReason.noMovesAvailable,
          moveCount: 1,
          elapsedSeconds: 0,
          livesRemaining: 3,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should decrement lives when TriggerArrowExit returns PathBlockedFailure',
      // Arrange
      setUp: () {
        fakeTriggerExit.result = Error<GameSession>(
          PathBlockedFailure(
            movingArrowId: 'arrow_1',
            blockingArrowId: 'arrow_2',
          ),
        );
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      // Assert
      expect: () => [
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          boardState: singleArrowBoard(),
          moveCount: 0,
          history: const CommandHistory(),
          score: initialScore,
          arrowsRemaining: 1,
          elapsedSeconds: 0,
          startedAtMs: clockValue,
          mistakes: 1,
          livesRemaining: 2,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit an ArrowCollisionEvent on arrowCollisions when blocked '
      '(regression: a blocked move had no visual collision feedback at all)',
      // Arrange
      setUp: () {
        fakeTriggerExit.result = Error<GameSession>(
          PathBlockedFailure(
            movingArrowId: 'arrow_1',
            blockingArrowId: 'arrow_2',
          ),
        );
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) async {
        final events = <ArrowCollisionEvent>[];
        final sub = bloc.arrowCollisions.listen(events.add);
        bloc.add(const TriggerArrowExit(arrowId: 'arrow_1'));
        await Future<void>.delayed(Duration.zero);
        expect(events, [
          const ArrowCollisionEvent(
            movingArrowId: 'arrow_1',
            blockingArrowId: 'arrow_2',
          ),
        ]);
        await sub.cancel();
      },
    );

    blocTest<GameBloc, GameState>(
      'should emit no new states when TriggerArrowExit returns ArrowNotFoundFailure',
      // Arrange
      setUp: () {
        fakeTriggerExit.result = Error<GameSession>(
          const ArrowNotFoundFailure(arrowId: 'arrow_1'),
        );
      },
      build: buildBloc,
      seed: playingSeed,
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      // Assert
      expect: () => <GameState>[],
    );
  });

  group('UndoMove', () {
    GamePlaying undoSeedState() {
      return GamePlaying(
        levelId: 1,
        difficulty: 'Easy',
        boardState: singleArrowBoard(),
        moveCount: 3,
        history: const CommandHistory().push(
          ArrowExitCommand(
            exitedArrow: singleArrowBoard().arrows.first,
            previousState: BoardState(arrows: const []),
          ),
        ),
        score: initialScore,
        arrowsRemaining: 1,
        elapsedSeconds: 0,
        startedAtMs: clockValue,
      );
    }

    GameSession revertedSession() {
      return GameSession(
        sessionId: 'session-1',
        boardState: singleArrowBoard(),
        startedAtMs: clockValue,
        moveCount: 2,
      );
    }

    blocTest<GameBloc, GameState>(
      'should emit updated GamePlaying with decremented moveCount when UndoMove succeeds',
      // Arrange
      setUp: () {
        fakeUndoMove.result = Success(revertedSession());
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 2,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: undoSeedState,
      // Act
      act: (bloc) => bloc.add(const UndoMove()),
      // Assert
      expect: () => [
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          boardState: singleArrowBoard(),
          moveCount: 2,
          history: const CommandHistory(),
          score: initialScore,
          arrowsRemaining: 1,
          elapsedSeconds: 0,
          startedAtMs: clockValue,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit no new states when UndoMove fails',
      // Arrange
      setUp: () {
        fakeUndoMove.result = Error<GameSession>(
          const GenericFailure('No moves to undo'),
        );
      },
      build: buildBloc,
      seed: undoSeedState,
      // Act
      act: (bloc) => bloc.add(const UndoMove()),
      // Assert
      expect: () => <GameState>[],
    );
  });

  group('Tick', () {
    GamePlaying tickSeedState() {
      return GamePlaying(
        levelId: 1,
        difficulty: 'Easy',
        boardState: singleArrowBoard(),
        moveCount: 0,
        history: const CommandHistory(),
        score: initialScore,
        arrowsRemaining: 1,
        elapsedSeconds: 0,
        startedAtMs: clockValue,
      );
    }

    const tickScore = Score(moves: 0, timeElapsed: 5, totalPoints: 500);

    blocTest<GameBloc, GameState>(
      'should emit updated GamePlaying when elapsed time changes',
      // Arrange
      setUp: () {
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: tickScore,
          moveCount: 0,
          elapsedSeconds: 5,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: tickSeedState,
      // Act
      act: (bloc) => bloc.add(const Tick(nowMs: 6000)),
      // Assert
      expect: () => [
        GamePlaying(
          levelId: 1,
          difficulty: 'Easy',
          boardState: singleArrowBoard(),
          moveCount: 0,
          history: const CommandHistory(),
          score: tickScore,
          arrowsRemaining: 1,
          elapsedSeconds: 5,
          startedAtMs: clockValue,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameDefeat] when time limit expires',
      // Arrange
      setUp: () {
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: tickScore,
          moveCount: 0,
          elapsedSeconds: 60,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: tickSeedState,
      // Act
      act: (bloc) => bloc.add(const Tick(nowMs: 61000)),
      // Assert
      expect: () => [
        const GameDefeat(
          levelId: 1,
          reason: DefeatReason.timeExpired,
          moveCount: 0,
          elapsedSeconds: 60,
          livesRemaining: 3,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit no new states when tick occurs within the same second',
      // Arrange
      setUp: () {
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
      },
      build: buildBloc,
      seed: tickSeedState,
      // Act
      act: (bloc) => bloc.add(const Tick(nowMs: clockValue + 500)),
      // Assert
      expect: () => <GameState>[],
    );
  });

  group('RetryLevel', () {
    Level retryLevel() {
      return Level(
        levelId: 1,
        geometry: const BoardGeometry2D(rows: 7, cols: 7),
        templateBoard: singleArrowBoard(),
      );
    }

    GameSession retrySession() {
      return GameSession(
        sessionId: 'retry-session',
        boardState: singleArrowBoard(),
        startedAtMs: clockValue,
      );
    }

    void arrangeRetrySuccess() {
      fakeLoadLevel.result = Success(retryLevel());
      fakeStartSession.result = Success(retrySession());
      fakeEvaluateState.result = const GameEvaluation(
        status: GameStatus.ongoing,
        score: initialScore,
        moveCount: 0,
        elapsedSeconds: 0,
        arrowsRemaining: 1,
      );
    }

    GamePlaying expectedRetryState() {
      return GamePlaying(
        levelId: 1,
        difficulty: 'Easy',
        rows: 7,
        cols: 7,
        boardState: singleArrowBoard(),
        moveCount: 0,
        history: const CommandHistory(),
        score: initialScore,
        arrowsRemaining: 1,
        elapsedSeconds: 0,
        startedAtMs: clockValue,
      );
    }

    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GamePlaying] when RetryLevel is triggered from GamePlaying',
      // Arrange
      setUp: arrangeRetrySuccess,
      build: buildBloc,
      seed: () => GamePlaying(
        levelId: 1,
        difficulty: 'Easy',
        boardState: singleArrowBoard(),
        moveCount: 5,
        history: const CommandHistory().push(
          ArrowExitCommand(
            exitedArrow: singleArrowBoard().arrows.first,
            previousState: BoardState(arrows: const []),
          ),
        ),
        score: initialScore,
        arrowsRemaining: 1,
        elapsedSeconds: 10,
        startedAtMs: clockValue,
      ),
      // Act
      act: (bloc) => bloc.add(const RetryLevel()),
      // Assert
      expect: () => [
        const GameLoading(levelId: 1),
        expectedRetryState(),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GamePlaying] when RetryLevel is triggered from GameDefeat',
      // Arrange
      setUp: arrangeRetrySuccess,
      build: buildBloc,
      seed: () => const GameDefeat(
        levelId: 1,
        reason: DefeatReason.timeExpired,
        moveCount: 10,
        elapsedSeconds: 60,
      ),
      // Act
      act: (bloc) => bloc.add(const RetryLevel()),
      // Assert
      expect: () => [
        const GameLoading(levelId: 1),
        expectedRetryState(),
      ],
    );

    blocTest<GameBloc, GameState>(
      'should emit [GameLoading, GamePlaying] when RetryLevel is triggered from GameVictory',
      // Arrange
      setUp: arrangeRetrySuccess,
      build: buildBloc,
      seed: () => const GameVictory(
        levelId: 1,
        score: Score(moves: 5, timeElapsed: 10, totalPoints: 1200),
        moveCount: 5,
        elapsedSeconds: 10,
      ),
      // Act
      act: (bloc) => bloc.add(const RetryLevel()),
      // Assert
      expect: () => [
        const GameLoading(levelId: 1),
        expectedRetryState(),
      ],
    );
  });

  group('Survival mode (endless) level counter', () {
    blocTest<GameBloc, GameState>(
      'should count levelsCompleted by 1 per level, not 2 '
      '(regression: victory and NextEndlessLevel used to both increment it)',
      build: buildBloc,
      act: (bloc) async {
        final level = Level(
          levelId: -1,
          geometry: const BoardGeometry2D(rows: 7, cols: 7),
          templateBoard: singleArrowBoard(),
        );
        final session = GameSession(
          sessionId: 'session--1',
          boardState: singleArrowBoard(),
          startedAtMs: clockValue,
        );
        fakeLoadLevel.result = Success(level);
        fakeStartSession.result = Success(session);
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );

        // Enter survival mode (negative level id).
        bloc.add(const LoadLevel(levelId: -1));
        await Future<void>.delayed(Duration.zero);

        // Win the level.
        final previousBoard = singleArrowBoard();
        final exitedArrow = previousBoard.arrows.first;
        fakeTriggerExit.result = Success(
          GameSession(
            sessionId: 'session--1',
            boardState: BoardState(arrows: const []),
            history: const CommandHistory().push(
              ArrowExitCommand(
                exitedArrow: exitedArrow,
                previousState: previousBoard,
              ),
            ),
            moveCount: 1,
            startedAtMs: clockValue,
          ),
        );
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.victory,
          score: evalScore,
          moveCount: 1,
          elapsedSeconds: 5,
          arrowsRemaining: 0,
        );
        fakeCalculateScore.result = const Success(finalScore);
        bloc.add(const TriggerArrowExit(arrowId: 'arrow_1'));
        // _onTriggerArrowExit awaits a 450ms exit-animation delay before
        // emitting GameVictory; wait past it so the counter increment lands.
        await Future<void>.delayed(const Duration(milliseconds: 550));

        // Move on to the next endless level.
        fakeEvaluateState.result = const GameEvaluation(
          status: GameStatus.ongoing,
          score: initialScore,
          moveCount: 0,
          elapsedSeconds: 0,
          arrowsRemaining: 1,
        );
        bloc.add(const NextEndlessLevel());
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<GamePlaying>());
        // Exactly one level was completed, so the counter must read 1 — not 2.
        expect((state as GamePlaying).levelsCompleted, 1);
      },
    );
  });

  group('Cross-cutting validations', () {
    blocTest<GameBloc, GameState>(
      'should emit no new states when TriggerArrowExit is received while not playing',
      // Arrange
      build: buildBloc,
      seed: () => const GameInitial(),
      // Act
      act: (bloc) => bloc.add(const TriggerArrowExit(arrowId: 'arrow_1')),
      // Assert
      expect: () => <GameState>[],
    );
  });
}
