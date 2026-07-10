import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes/fake_level_repository.dart';
import '../../../../helpers/fakes/fake_progress_repository.dart';

void main() {
  group('MenuBloc', () {
    late FakeLevelRepository fakeLevelRepository;
    late FakeProgressRepository fakeProgressRepository;
    late GetLevelListUseCase getLevelListUseCase;

    setUp(() {
      fakeLevelRepository = FakeLevelRepository();
      fakeProgressRepository = FakeProgressRepository();
      getLevelListUseCase = GetLevelListUseCase(
        fakeLevelRepository,
        fakeProgressRepository,
      );
    });

    MenuBloc buildBloc() {
      return MenuBloc(getLevelListUseCase: getLevelListUseCase);
    }

    test('should_start_with_initial_state', () {
      expect(buildBloc().state, const MenuInitial());
    });

    group('MenuLevelsRequested', () {
      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuLevelsLoaded] when the use case succeeds',
        setUp: () {
          fakeLevelRepository.countResult = const Success<int>(3);
          fakeProgressRepository.loadResult = const Success<AppProgress>(
            AppProgress(unlockedLevels: [1]),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const MenuLevelsRequested()),
        expect: () => [
          const MenuLoading(),
          const MenuLevelsLoaded(
            levels: [
              LevelSummary(levelId: 1, isUnlocked: true),
              LevelSummary(levelId: 2, isUnlocked: false),
              LevelSummary(levelId: 3, isUnlocked: false),
            ],
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuLoadFailure] when the level count fails',
        setUp: () {
          fakeLevelRepository.countResult = const Error<int>(
            GenericFailure('Level count unavailable'),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const MenuLevelsRequested()),
        expect: () => [
          const MenuLoading(),
          const MenuLoadFailure(message: 'Level count unavailable'),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'should emit [MenuLoading, MenuLoadFailure] when loading progress fails',
        setUp: () {
          fakeLevelRepository.countResult = const Success<int>(2);
          fakeProgressRepository.loadResult = const Error<AppProgress>(
            GenericFailure('Progress unavailable'),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const MenuLevelsRequested()),
        expect: () => [
          const MenuLoading(),
          const MenuLoadFailure(message: 'Progress unavailable'),
        ],
      );
    });
  });
}
