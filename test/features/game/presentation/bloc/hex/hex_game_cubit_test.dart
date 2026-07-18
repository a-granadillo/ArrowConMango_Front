import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_graph.dart';
import 'package:arrowconmango_front/features/game/data/topologies/hex_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_level.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_hex_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/cube_mango_scoring.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
import 'package:arrowconmango_front/features/game/presentation/bloc/hex/hex_game_cubit.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/hex/hex_game_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// A deterministic, manually-advanced clock so elapsed-time-dependent
/// assertions (ticks, score) don't depend on real wall-clock speed.
class _FakeClock {
  _FakeClock(this._nowMs);
  int _nowMs;
  int call() => _nowMs;
  void advance(int ms) => _nowMs += ms;
}

/// In-memory [IHexLevelRepository] returning a fixed catalogue — the
/// hexagonal mode's own repository does network/generator work this cubit
/// shouldn't have to fake around.
class _FakeHexLevelRepository implements IHexLevelRepository {
  _FakeHexLevelRepository(this.levels);

  final List<HexLevel> levels;
  final List<String> submittedLevelIds = [];

  @override
  Future<Result<List<HexLevel>>> getLevels() async =>
      Success<List<HexLevel>>(levels);

  @override
  Future<Result<void>> submitScore({
    required String levelId,
    required int moves,
    required int elapsedSeconds,
  }) async {
    submittedLevelIds.add(levelId);
    return const Success<void>(null);
  }
}

HexLevel _levelOf(
  String id,
  List<ArrowEntity> arrows, {
  required int radius,
}) {
  return HexLevel(
    id: id,
    name: 'Test $id',
    difficulty: 'Easy',
    radius: radius,
    templateBoard: BoardState(arrows: arrows),
  );
}

/// Builds a cubit backed by the REAL [TriggerArrowExitUseCase] and
/// [CollisionValidator] over a [HexTopology] of the given radius — both are
/// pure, deterministic domain classes, so faking them would only obscure the
/// behavior under test.
HexGameCubit _buildCubit({
  required int radius,
  required List<HexLevel> levels,
  int Function()? clock,
}) {
  final validator = CollisionValidator(HexTopology(radius: radius));
  return HexGameCubit(
    triggerArrowExitUseCase: TriggerArrowExitUseCase(validator),
    collisionValidator: validator,
    hexLevelRepository: _FakeHexLevelRepository(levels),
    clock: clock,
  );
}

void main() {
  group('HexGameCubit', () {
    late _FakeClock sharedClock;

    // A 2-cell strip on a radius-1 board: 'a' points se into 'b' (blocked);
    // 'b' points se into the boundary (always free — radius 1 has nothing
    // beyond (1,0) in that direction).
    final arrowA = const ArrowEntity(
      id: 'a',
      direction: HexDirection.se,
      occupiedNodes: [HexNodeId(q: 0, r: 0)],
    );
    final arrowB = const ArrowEntity(
      id: 'b',
      direction: HexDirection.se,
      occupiedNodes: [HexNodeId(q: 1, r: 0)],
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_count_a_blocked_tap_as_both_a_move_and_a_mistake',
      build: () => _buildCubit(
        radius: 1,
        levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
      ),
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('a');
      },
      verify: (cubit) {
        expect(cubit.state.status, HexStatus.playing);
        expect(cubit.state.lastBlockedId, 'a');
        expect(cubit.state.board!.arrowCount, 2);
        expect(cubit.state.moveCount, 1, reason: 'wrong taps must still count as moves');
        expect(cubit.state.mistakes, 1);
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_remove_arrow_and_recompute_exitable_when_tap_succeeds',
      build: () => _buildCubit(
        radius: 1,
        levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
      ),
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('b');
      },
      verify: (cubit) {
        expect(cubit.state.status, HexStatus.playing);
        expect(cubit.state.board!.arrowCount, 1);
        expect(cubit.state.moveCount, 1);
        expect(cubit.state.mistakes, 0);
        expect(cubit.state.exitableIds, {'a'});
        expect(cubit.state.lastBlockedId, isNull);
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_emit_victory_with_a_computed_score_and_submit_the_score_when_the_last_arrow_exits',
      build: () {
        final clock = _FakeClock(1000000);
        return _buildCubit(
          radius: 1,
          levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
          clock: clock.call,
        );
      },
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('b');
        cubit.tapArrow('a');
      },
      verify: (cubit) {
        expect(cubit.state.status, HexStatus.victory);
        expect(cubit.state.board!.isEmpty, isTrue);
        expect(cubit.state.moveCount, 2);
        expect(cubit.state.mistakes, 0);
        expect(
          cubit.state.score,
          CubeMangoScoring.calculate(moves: 2, seconds: 0, mistakes: 0),
        );
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_penalize_the_score_for_elapsed_time_and_mistakes',
      build: () {
        sharedClock = _FakeClock(1000000);
        return _buildCubit(
          radius: 1,
          levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
          clock: sharedClock.call,
        );
      },
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('a'); // blocked: 1 mistake
        sharedClock.advance(2500); // +2s (floored)
        cubit.tapArrow('b'); // succeeds
        cubit.tapArrow('a'); // now clear: victory
      },
      verify: (cubit) {
        expect(cubit.state.status, HexStatus.victory);
        expect(cubit.state.mistakes, 1);
        expect(cubit.state.moveCount, 3);
        expect(
          cubit.state.score,
          CubeMangoScoring.calculate(moves: 3, seconds: 2, mistakes: 1),
        );
        final clean = CubeMangoScoring.calculate(moves: 3, seconds: 2, mistakes: 0);
        expect(cubit.state.score!.totalPoints, lessThan(clean.totalPoints));
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_emit_defeat_when_the_remaining_arrows_are_mutually_blocked',
      build: () => _buildCubit(
        radius: 2,
        levels: [
          _levelOf(
            'h1',
            [
              const ArrowEntity(
                id: 'a',
                direction: HexDirection.se,
                occupiedNodes: [HexNodeId(q: 0, r: 0)],
              ),
              const ArrowEntity(
                id: 'b',
                direction: HexDirection.nw,
                occupiedNodes: [HexNodeId(q: 1, r: 0)],
              ),
              const ArrowEntity(
                id: 'c',
                direction: HexDirection.se,
                occupiedNodes: [HexNodeId(q: 2, r: 0)],
              ),
            ],
            radius: 2,
          ),
        ],
      ),
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('c');
      },
      verify: (cubit) {
        expect(cubit.state.status, HexStatus.defeat);
        expect(cubit.state.defeatReason, DefeatReason.noMovesAvailable);
        expect(cubit.state.board!.arrowCount, 2);
        expect(cubit.state.exitableIds, isEmpty);
        expect(cubit.state.score, isNull);
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_emit_defeat_once_maxMistakes_blocked_taps_are_reached',
      build: () => _buildCubit(
        radius: 1,
        levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
      ),
      act: (cubit) async {
        await cubit.loadLevels();
        for (var i = 0; i < CubeMangoScoring.maxMistakes; i++) {
          cubit.tapArrow('a');
        }
      },
      verify: (cubit) {
        expect(cubit.state.mistakes, CubeMangoScoring.maxMistakes);
        expect(cubit.state.status, HexStatus.defeat);
        expect(cubit.state.defeatReason, DefeatReason.outOfLives);
        expect(cubit.state.moveCount, CubeMangoScoring.maxMistakes);
        expect(cubit.state.score, isNull);
        expect(cubit.state.board!.arrowCount, 2);
      },
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_clear_lastBlockedId_when_clearBlockedFlash_is_called',
      build: () => _buildCubit(
        radius: 1,
        levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
      ),
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tapArrow('a');
        cubit.clearBlockedFlash();
      },
      verify: (cubit) => expect(cubit.state.lastBlockedId, isNull),
    );

    blocTest<HexGameCubit, HexGameState>(
      'should_advance_elapsedSeconds_on_tick',
      build: () {
        final clock = _FakeClock(2000000);
        return _buildCubit(
          radius: 1,
          levels: [_levelOf('h1', [arrowA, arrowB], radius: 1)],
          clock: clock.call,
        );
      },
      act: (cubit) async {
        await cubit.loadLevels();
        cubit.tick();
      },
      verify: (cubit) => expect(cubit.state.elapsedSeconds, 0),
    );

    group('progression', () {
      final level1 = _levelOf('h1', [arrowA, arrowB], radius: 1);
      final level2 = _levelOf(
        'h2',
        [
          const ArrowEntity(
            id: 'x',
            direction: HexDirection.se,
            occupiedNodes: [HexNodeId(q: 0, r: 0)],
          ),
        ],
        radius: 1,
      );

      blocTest<HexGameCubit, HexGameState>(
        'should_report_hasNextLevel_when_more_levels_remain',
        build: () => _buildCubit(radius: 1, levels: [level1, level2]),
        act: (cubit) => cubit.loadLevels(),
        verify: (cubit) {
          expect(cubit.state.levelIndex, 0);
          expect(cubit.state.totalLevels, 2);
          expect(cubit.state.hasNextLevel, isTrue);
        },
      );

      blocTest<HexGameCubit, HexGameState>(
        'should_advance_to_the_next_level_when_nextLevel_is_called_after_victory',
        build: () => _buildCubit(radius: 1, levels: [level1, level2]),
        act: (cubit) async {
          await cubit.loadLevels();
          cubit.tapArrow('b');
          cubit.tapArrow('a'); // clears level1 -> victory
          cubit.nextLevel();
        },
        verify: (cubit) {
          expect(cubit.state.status, HexStatus.playing);
          expect(cubit.state.levelIndex, 1);
          expect(cubit.state.hasNextLevel, isFalse);
          expect(cubit.state.board!.arrowCount, 1);
        },
      );

      blocTest<HexGameCubit, HexGameState>(
        'should_do_nothing_when_nextLevel_is_called_on_the_last_level',
        build: () => _buildCubit(radius: 1, levels: [level1]),
        act: (cubit) async {
          await cubit.loadLevels();
          cubit.tapArrow('b');
          cubit.tapArrow('a'); // clears the only level -> victory
          cubit.nextLevel();
        },
        verify: (cubit) {
          expect(cubit.state.status, HexStatus.victory);
          expect(cubit.state.hasNextLevel, isFalse);
        },
      );

      blocTest<HexGameCubit, HexGameState>(
        'should_restart_the_same_level_when_retryLevel_is_called',
        build: () => _buildCubit(radius: 1, levels: [level1]),
        act: (cubit) async {
          await cubit.loadLevels();
          cubit.tapArrow('a'); // mistake
          cubit.retryLevel();
        },
        verify: (cubit) {
          expect(cubit.state.status, HexStatus.playing);
          expect(cubit.state.mistakes, 0);
          expect(cubit.state.moveCount, 0);
          expect(cubit.state.board!.arrowCount, 2);
        },
      );
    });
  });
}
