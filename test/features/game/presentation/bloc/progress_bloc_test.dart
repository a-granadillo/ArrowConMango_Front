import 'package:arrowconmango_front/features/game/application/use_cases/load_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/save_local_progress_use_case.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/unlock_next_level_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/progress_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';
import '../../../../helpers/fakes/fake_progress_repository.dart';

void main() {
  group('ProgressBloc', () {
    late FakeProgressRepository fakeProgressRepository;
    late FakeLevelRepository fakeLevelRepository;
    late LoadProgressUseCase loadProgressUseCase;
    late UnlockNextLevelUseCase unlockNextLevelUseCase;
    late SaveLocalProgressUseCase saveLocalProgressUseCase;

    setUp(() {
      fakeProgressRepository = FakeProgressRepository();
      fakeLevelRepository = FakeLevelRepository();
      loadProgressUseCase = LoadProgressUseCase(fakeProgressRepository);
      unlockNextLevelUseCase = UnlockNextLevelUseCase(
        fakeProgressRepository,
        fakeLevelRepository,
      );
      saveLocalProgressUseCase = SaveLocalProgressUseCase(
        fakeProgressRepository,
      );
    });

    ProgressBloc buildBloc() {
      return ProgressBloc(
        loadProgressUseCase: loadProgressUseCase,
        unlockNextLevelUseCase: unlockNextLevelUseCase,
        saveLocalProgressUseCase: saveLocalProgressUseCase,
      );
    }

    test('should_start_with_initial_state', () {
      expect(buildBloc().state, const ProgressInitial());
    });

    group('ProgressRequested', () {
      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressLoaded] when loading progress succeeds',
        setUp: () {
          fakeProgressRepository.loadResult = const Success<AppProgress>(
            AppProgress(unlockedLevels: [1, 2]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgressRequested()),
        expect: () => [
          const ProgressLoading(),
          const ProgressLoaded(
            progress: AppProgress(unlockedLevels: [1, 2]),
          ),
        ],
      );

      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressFailure] when loading progress fails',
        setUp: () {
          fakeProgressRepository.loadResult = const Error<AppProgress>(
            GenericFailure('Progress unavailable'),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgressRequested()),
        expect: () => [
          const ProgressLoading(),
          const ProgressFailure(message: 'Progress unavailable'),
        ],
      );
    });

    group('ProgressLevelUnlocked', () {
      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressLoaded] with the next level unlocked when unlocking succeeds',
        setUp: () {
          fakeProgressRepository.loadResult = const Success<AppProgress>(
            AppProgress(unlockedLevels: [1]),
          );
          fakeLevelRepository.countResult = const Success<int>(3);
          fakeProgressRepository.saveResult = const Success<void>(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgressLevelUnlocked(currentLevelId: 1)),
        expect: () => [
          const ProgressLoading(),
          const ProgressLoaded(
            progress: AppProgress(unlockedLevels: [1, 2]),
          ),
        ],
        verify: (_) {
          expect(
            fakeProgressRepository.savedProgress,
            const AppProgress(unlockedLevels: [1, 2]),
          );
        },
      );

      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressFailure] when the next level does not exist',
        setUp: () {
          fakeProgressRepository.loadResult = const Success<AppProgress>(
            AppProgress(unlockedLevels: [1, 2, 3]),
          );
          fakeLevelRepository.countResult = const Success<int>(3);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgressLevelUnlocked(currentLevelId: 3)),
        expect: () => [
          const ProgressLoading(),
          isA<ProgressFailure>().having(
            (state) => state.message,
            'message',
            contains('4'),
          ),
        ],
      );

      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressFailure] when loading progress fails before unlocking',
        setUp: () {
          fakeProgressRepository.loadResult = const Error<AppProgress>(
            GenericFailure('Progress unavailable'),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ProgressLevelUnlocked(currentLevelId: 1)),
        expect: () => [
          const ProgressLoading(),
          const ProgressFailure(message: 'Progress unavailable'),
        ],
      );
    });

    group('ProgressSaved', () {
      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressLoaded] when saving succeeds',
        setUp: () {
          fakeProgressRepository.saveResult = const Success<void>(null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProgressSaved(
            progress: AppProgress(unlockedLevels: [1]),
          ),
        ),
        expect: () => [
          const ProgressLoading(),
          const ProgressLoaded(
            progress: AppProgress(unlockedLevels: [1]),
          ),
        ],
        verify: (_) {
          expect(
            fakeProgressRepository.savedProgress,
            const AppProgress(unlockedLevels: [1]),
          );
        },
      );

      blocTest<ProgressBloc, ProgressState>(
        'should emit [ProgressLoading, ProgressFailure] when saving fails',
        setUp: () {
          fakeProgressRepository.saveResult = const Error<void>(
            GenericFailure('Could not save progress'),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ProgressSaved(progress: AppProgress()),
        ),
        expect: () => [
          const ProgressLoading(),
          const ProgressFailure(message: 'Could not save progress'),
        ],
      );
    });
  });
}
