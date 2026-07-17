import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/submit_score_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level_best.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/errors/level_not_found_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/move_based_scoring.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Manual fakes for the domain use cases used by [ProgressBloc].
// ---------------------------------------------------------------------------

class FakeLoadProgressUseCase implements LoadProgressUseCase {
  Result<AppProgress>? result;
  int calledCount = 0;

  @override
  Future<Result<AppProgress>> call() async {
    calledCount++;
    final configured = result;
    if (configured == null) {
      throw StateError('Configure FakeLoadProgressUseCase.result in Arrange');
    }
    return configured;
  }
}

class FakeSaveLocalProgressUseCase implements SaveLocalProgressUseCase {
  Result<void>? result;
  AppProgress? calledProgress;

  @override
  Future<Result<void>> call({required AppProgress progress}) async {
    calledProgress = progress;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeSaveLocalProgressUseCase.result in Arrange',
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

class FakeSubmitScoreUseCase implements SubmitScoreUseCase {
  ({int levelId, int moves, int elapsedSeconds})? calledWith;

  @override
  Future<void> call({
    required int levelId,
    required int moves,
    required int elapsedSeconds,
  }) async {
    calledWith = (levelId: levelId, moves: moves, elapsedSeconds: elapsedSeconds);
  }
}

void main() {
  late FakeLoadProgressUseCase fakeLoad;
  late FakeSaveLocalProgressUseCase fakeSave;
  late FakeUnlockNextLevelUseCase fakeUnlock;
  late FakeSubmitScoreUseCase fakeSubmitScore;

  setUp(() {
    fakeLoad = FakeLoadProgressUseCase();
    fakeSave = FakeSaveLocalProgressUseCase();
    fakeUnlock = FakeUnlockNextLevelUseCase();
    fakeSubmitScore = FakeSubmitScoreUseCase();
  });

  ProgressBloc buildBloc() {
    return ProgressBloc(
      loadProgressUseCase: fakeLoad,
      saveLocalProgressUseCase: fakeSave,
      unlockNextLevelUseCase: fakeUnlock,
      submitScoreUseCase: fakeSubmitScore,
      scoringStrategy: const MoveBasedScoring(),
    );
  }

  group('ProgressLoadStarted', () {
    blocTest<ProgressBloc, ProgressState>(
      'should emit [ProgressLoading, ProgressLoaded] when load succeeds',
      // Arrange
      setUp: () {
        fakeLoad.result = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 2], currentLevel: 2),
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const ProgressLoadStarted()),
      // Assert
      expect: () => [
        const ProgressLoading(),
        const ProgressLoaded(
          progress: AppProgress(unlockedLevels: [1, 2], currentLevel: 2),
        ),
      ],
      verify: (_) {
        expect(fakeLoad.calledCount, equals(1));
      },
    );

    blocTest<ProgressBloc, ProgressState>(
      'should emit [ProgressLoading, ProgressError] when load fails',
      // Arrange
      setUp: () {
        fakeLoad.result = Error<AppProgress>(
          const GenericFailure('storage unavailable'),
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const ProgressLoadStarted()),
      // Assert
      expect: () => [
        const ProgressLoading(),
        const ProgressError(message: 'storage unavailable'),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'should stay idempotent when progress is already loaded',
      // Arrange
      build: buildBloc,
      seed: () => const ProgressLoaded(
        progress: AppProgress(unlockedLevels: [1], currentLevel: 1),
      ),
      // Act
      act: (bloc) => bloc.add(const ProgressLoadStarted()),
      // Assert
      expect: () => <ProgressState>[],
      verify: (_) {
        expect(fakeLoad.calledCount, equals(0));
      },
    );
  });

  group('ProgressLevelCompleted', () {
    blocTest<ProgressBloc, ProgressState>(
      'should unlock next level and save when both succeed',
      // Arrange
      setUp: () {
        fakeUnlock.result = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 2, 3], currentLevel: 3),
        );
        fakeSave.result = const Success<void>(null);
      },
      build: buildBloc,
      seed: () => const ProgressLoaded(
        progress: AppProgress(unlockedLevels: [1, 2], currentLevel: 2),
      ),
      // Act
      act: (bloc) => bloc.add(
        const ProgressLevelCompleted(
          currentLevelId: 2,
          moves: 10,
          elapsedSeconds: 20,
        ),
      ),
      // Assert
      expect: () => [
        const ProgressLoaded(
          progress: AppProgress(
            unlockedLevels: [1, 2, 3],
            currentLevel: 3,
            best: {2: LevelBest(moves: 10, timeElapsedSeconds: 20)},
          ),
        ),
      ],
      verify: (_) {
        expect(fakeUnlock.calledCurrentLevelId, equals(2));
        expect(
          fakeSave.calledProgress,
          equals(
            const AppProgress(
              unlockedLevels: [1, 2, 3],
              currentLevel: 3,
              best: {2: LevelBest(moves: 10, timeElapsedSeconds: 20)},
            ),
          ),
        );
        expect(
          fakeSubmitScore.calledWith,
          equals((levelId: 2, moves: 10, elapsedSeconds: 20)),
        );
      },
    );

    blocTest<ProgressBloc, ProgressState>(
      'should record the best run for the last level (no next level to '
      'unlock) when unlocking fails with LevelNotFoundFailure',
      // Arrange
      setUp: () {
        fakeUnlock.result = Error<AppProgress>(
          const LevelNotFoundFailure(levelId: 16),
        );
        fakeSave.result = const Success<void>(null);
      },
      build: buildBloc,
      seed: () => const ProgressLoaded(
        progress: AppProgress(
          unlockedLevels: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
          currentLevel: 15,
        ),
      ),
      // Act
      act: (bloc) => bloc.add(
        const ProgressLevelCompleted(
          currentLevelId: 15,
          moves: 3,
          elapsedSeconds: 5,
        ),
      ),
      // Assert
      expect: () => [
        const ProgressLoaded(
          progress: AppProgress(
            unlockedLevels: [
              1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
            ],
            currentLevel: 15,
            best: {15: LevelBest(moves: 3, timeElapsedSeconds: 5)},
          ),
        ),
      ],
      verify: (_) {
        expect(fakeUnlock.calledCurrentLevelId, equals(15));
        expect(
          fakeSave.calledProgress,
          equals(
            const AppProgress(
              unlockedLevels: [
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
              ],
              currentLevel: 15,
              best: {15: LevelBest(moves: 3, timeElapsedSeconds: 5)},
            ),
          ),
        );
      },
    );

    blocTest<ProgressBloc, ProgressState>(
      'should emit ProgressError when unlock succeeds but save fails',
      // Arrange
      setUp: () {
        fakeUnlock.result = const Success<AppProgress>(
          AppProgress(unlockedLevels: [1, 2], currentLevel: 2),
        );
        fakeSave.result = Error<void>(
          const GenericFailure('save failed'),
        );
      },
      build: buildBloc,
      seed: () => const ProgressLoaded(
        progress: AppProgress(unlockedLevels: [1], currentLevel: 1),
      ),
      // Act
      act: (bloc) => bloc.add(
        const ProgressLevelCompleted(
          currentLevelId: 1,
          moves: 8,
          elapsedSeconds: 12,
        ),
      ),
      // Assert
      expect: () => [
        const ProgressError(message: 'save failed'),
      ],
      verify: (_) {
        expect(fakeUnlock.calledCurrentLevelId, equals(1));
        expect(
          fakeSave.calledProgress,
          equals(
            const AppProgress(
              unlockedLevels: [1, 2],
              currentLevel: 2,
              best: {1: LevelBest(moves: 8, timeElapsedSeconds: 12)},
            ),
          ),
        );
      },
    );
  });

  group('ProgressUpdatedExternally', () {
    blocTest<ProgressBloc, ProgressState>(
      'should emit ProgressLoaded with the provided progress',
      // Arrange
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(
        const ProgressUpdatedExternally(
          progress: AppProgress(
            unlockedLevels: [1, 2, 3],
            currentLevel: 3,
          ),
        ),
      ),
      // Assert
      expect: () => [
        const ProgressLoaded(
          progress: AppProgress(
            unlockedLevels: [1, 2, 3],
            currentLevel: 3,
          ),
        ),
      ],
    );
  });
}
