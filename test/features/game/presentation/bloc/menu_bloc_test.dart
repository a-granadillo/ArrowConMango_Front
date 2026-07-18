import 'package:arrowconmango_front/features/game/application/dtos/level_summary.dart';
import 'package:arrowconmango_front/features/game/application/use_cases/get_level_list_use_case.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_bloc.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_event.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/menu_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Manual fake for the domain use case used by [MenuBloc].
// ---------------------------------------------------------------------------

class FakeGetLevelListUseCase implements GetLevelListUseCase {
  Result<List<LevelSummary>>? result;
  int calledCount = 0;

  @override
  Future<Result<List<LevelSummary>>> call() async {
    calledCount++;
    final configured = result;
    if (configured == null) {
      throw StateError(
        'Configure FakeGetLevelListUseCase.result in Arrange',
      );
    }
    return configured;
  }
}

void main() {
  late FakeGetLevelListUseCase fakeGetLevelList;

  setUp(() {
    fakeGetLevelList = FakeGetLevelListUseCase();
  });

  MenuBloc buildBloc() {
    return MenuBloc(getLevelListUseCase: fakeGetLevelList);
  }

  group('MenuLevelsRequested', () {
    blocTest<MenuBloc, MenuState>(
      'should emit [MenuLoading, MenuLoaded] when load succeeds',
      // Arrange
      setUp: () {
        fakeGetLevelList.result = Success<List<LevelSummary>>([
          const LevelSummary(levelId: 1, isUnlocked: true),
          const LevelSummary(levelId: 2, isUnlocked: false),
        ]);
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const MenuLevelsRequested()),
      // Assert
      expect: () => [
        const MenuLoading(),
        const MenuLoaded(
          levels: [
            LevelSummary(levelId: 1, isUnlocked: true),
            LevelSummary(levelId: 2, isUnlocked: false),
          ],
        ),
      ],
      verify: (_) {
        expect(fakeGetLevelList.calledCount, equals(1));
      },
    );

    blocTest<MenuBloc, MenuState>(
      'should emit [MenuLoading, MenuError] when load fails',
      // Arrange
      setUp: () {
        fakeGetLevelList.result = Error<List<LevelSummary>>(
          const GenericFailure('cannot reach repository'),
        );
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const MenuLevelsRequested()),
      // Assert
      expect: () => [
        const MenuLoading(),
        const MenuError(message: 'cannot reach repository'),
      ],
    );

    blocTest<MenuBloc, MenuState>(
      'should emit [MenuLoading, MenuLoaded] with an empty list',
      // Arrange
      setUp: () {
        fakeGetLevelList.result = Success<List<LevelSummary>>([]);
      },
      build: buildBloc,
      // Act
      act: (bloc) => bloc.add(const MenuLevelsRequested()),
      // Assert
      expect: () => [
        const MenuLoading(),
        const MenuLoaded(levels: []),
      ],
    );
  });

  group('MenuLevelsRefreshed', () {
    blocTest<MenuBloc, MenuState>(
      'should refresh silently without emitting MenuLoading',
      // Arrange
      setUp: () {
        fakeGetLevelList.result = Success<List<LevelSummary>>([
          const LevelSummary(levelId: 1, isUnlocked: true),
          const LevelSummary(levelId: 2, isUnlocked: true),
          const LevelSummary(levelId: 3, isUnlocked: false),
        ]);
      },
      build: buildBloc,
      seed: () => const MenuLoaded(
        levels: [
          LevelSummary(levelId: 1, isUnlocked: true),
          LevelSummary(levelId: 2, isUnlocked: false),
          LevelSummary(levelId: 3, isUnlocked: false),
        ],
      ),
      // Act
      act: (bloc) => bloc.add(const MenuLevelsRefreshed()),
      // Assert
      expect: () => [
        const MenuLoaded(
          levels: [
            LevelSummary(levelId: 1, isUnlocked: true),
            LevelSummary(levelId: 2, isUnlocked: true),
            LevelSummary(levelId: 3, isUnlocked: false),
          ],
        ),
      ],
      verify: (_) {
        expect(fakeGetLevelList.calledCount, equals(1));
      },
    );

    blocTest<MenuBloc, MenuState>(
      'should emit MenuError when silent refresh fails',
      // Arrange
      setUp: () {
        fakeGetLevelList.result = Error<List<LevelSummary>>(
          const GenericFailure('refresh failed'),
        );
      },
      build: buildBloc,
      seed: () => const MenuLoaded(
        levels: [
          LevelSummary(levelId: 1, isUnlocked: true),
          LevelSummary(levelId: 2, isUnlocked: false),
        ],
      ),
      // Act
      act: (bloc) => bloc.add(const MenuLevelsRefreshed()),
      // Assert
      expect: () => [
        const MenuError(message: 'refresh failed'),
      ],
    );
  });
}
