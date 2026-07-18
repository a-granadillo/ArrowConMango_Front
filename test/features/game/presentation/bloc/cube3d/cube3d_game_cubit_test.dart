import 'package:arrowconmango_front/features/game/application/use_cases/trigger_arrow_exit_use_case.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_3d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/arrow_entity.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/level.dart';
import 'package:arrowconmango_front/features/game/domain/entities/spatial_direction.dart';
import 'package:arrowconmango_front/features/game/domain/services/collision_validator.dart';
import 'package:arrowconmango_front/features/game/domain/services/cube_mango_scoring.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/cube3d/cube3d_game_cubit.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/cube3d/cube3d_game_state.dart';
import 'package:arrowconmango_front/features/game/presentation/bloc/game_state.dart'
    show DefeatReason;
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

/// Builds a cubit backed by the REAL [TriggerArrowExitUseCase] and
/// [CollisionValidator] over a [Grid3DTopology] of the given size — both are
/// pure, deterministic domain classes, so faking them would only obscure
/// the behavior under test.
Cube3DGameCubit _buildCubit({
  required int width,
  required int height,
  required int depth,
  int Function()? clock,
}) {
  final validator = CollisionValidator(
    Grid3DTopology(width: width, height: height, depth: depth),
  );
  return Cube3DGameCubit(
    triggerArrowExitUseCase: TriggerArrowExitUseCase(validator),
    collisionValidator: validator,
    clock: clock,
  );
}

Level _levelOf(
  List<ArrowEntity> arrows, {
  required int width,
  required int height,
  required int depth,
}) {
  return Level(
    levelId: -1,
    name: 'Test Cube',
    geometry: BoardGeometry3D(rows: height, cols: width, depth: depth),
    templateBoard: BoardState(arrows: arrows),
  );
}

void main() {
  group('Cube3DGameCubit', () {
    // Shared between one test's `build` and `act` so the fake clock can be
    // advanced mid-scenario (blocTest doesn't expose the built cubit's
    // dependencies to `act`, only the cubit instance itself).
    late _FakeClock sharedClock;

    // A 2x1x1 board: 'a' points right into 'b' (blocked); 'b' points right
    // into the boundary (always free — nothing occupies the cell beyond it).
    final arrowA = const ArrowEntity(
      id: 'a',
      direction: SpatialDirection.right,
      occupiedNodes: [Cube3DNodeId(x: 0, y: 0, z: 0)],
    );
    final arrowB = const ArrowEntity(
      id: 'b',
      direction: SpatialDirection.right,
      occupiedNodes: [Cube3DNodeId(x: 1, y: 0, z: 0)],
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_count_a_blocked_tap_as_both_a_move_and_a_mistake',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('a');
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.playing);
        expect(cubit.state.lastBlockedId, 'a');
        expect(cubit.state.board!.arrowCount, 2);
        expect(cubit.state.moveCount, 1, reason: 'wrong taps must still count as moves');
        expect(cubit.state.mistakes, 1);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_remove_arrow_and_recompute_exitable_when_tap_succeeds',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('b');
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.playing);
        expect(cubit.state.board!.arrowCount, 1);
        expect(cubit.state.moveCount, 1);
        expect(cubit.state.mistakes, 0);
        expect(cubit.state.exitableIds, {'a'});
        expect(cubit.state.lastBlockedId, isNull);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_emit_victory_with_a_computed_score_when_the_last_arrow_exits',
      build: () {
        final clock = _FakeClock(1000000);
        return _buildCubit(width: 2, height: 1, depth: 1, clock: clock.call);
      },
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('b');
        cubit.tapArrow('a');
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.victory);
        expect(cubit.state.board!.isEmpty, isTrue);
        expect(cubit.state.moveCount, 2);
        expect(cubit.state.mistakes, 0);
        expect(
          cubit.state.score,
          CubeMangoScoring.calculate(moves: 2, seconds: 0, mistakes: 0),
        );
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_penalize_the_score_for_elapsed_time_and_mistakes',
      build: () {
        sharedClock = _FakeClock(1000000);
        return _buildCubit(width: 2, height: 1, depth: 1, clock: sharedClock.call);
      },
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('a'); // blocked: 1 mistake
        sharedClock.advance(2500); // +2s (floored)
        cubit.tapArrow('b'); // succeeds
        cubit.tapArrow('a'); // now clear: victory
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.victory);
        expect(cubit.state.mistakes, 1);
        expect(cubit.state.moveCount, 3);
        expect(
          cubit.state.score,
          CubeMangoScoring.calculate(moves: 3, seconds: 2, mistakes: 1),
        );
        // Sanity check that mistakes actually cost points vs. a clean run.
        final clean = CubeMangoScoring.calculate(moves: 3, seconds: 2, mistakes: 0);
        expect(cubit.state.score!.totalPoints, lessThan(clean.totalPoints));
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_emit_defeat_when_the_remaining_arrows_are_mutually_blocked',
      build: () => _buildCubit(width: 3, height: 1, depth: 1),
      act: (cubit) {
        // 'a' blocked by 'b'; 'b' blocked by 'a'; 'c' always free (boundary
        // immediately ahead). Clearing 'c' leaves an unsolvable a<->b pair.
        const a = ArrowEntity(
          id: 'a',
          direction: SpatialDirection.right,
          occupiedNodes: [Cube3DNodeId(x: 0, y: 0, z: 0)],
        );
        const b = ArrowEntity(
          id: 'b',
          direction: SpatialDirection.left,
          occupiedNodes: [Cube3DNodeId(x: 1, y: 0, z: 0)],
        );
        const c = ArrowEntity(
          id: 'c',
          direction: SpatialDirection.right,
          occupiedNodes: [Cube3DNodeId(x: 2, y: 0, z: 0)],
        );
        cubit.load(_levelOf([a, b, c], width: 3, height: 1, depth: 1));
        cubit.tapArrow('c');
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.defeat);
        expect(cubit.state.defeatReason, DefeatReason.noMovesAvailable);
        expect(cubit.state.board!.arrowCount, 2);
        expect(cubit.state.exitableIds, isEmpty);
        expect(cubit.state.score, isNull);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_emit_defeat_once_maxMistakes_blocked_taps_are_reached',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        // 'a' is blocked by 'b' every time — tap it repeatedly.
        for (var i = 0; i < CubeMangoScoring.maxMistakes; i++) {
          cubit.tapArrow('a');
        }
      },
      verify: (cubit) {
        expect(cubit.state.mistakes, CubeMangoScoring.maxMistakes);
        expect(cubit.state.status, Cube3DStatus.defeat);
        expect(cubit.state.defeatReason, DefeatReason.outOfLives);
        expect(cubit.state.moveCount, CubeMangoScoring.maxMistakes);
        expect(cubit.state.score, isNull);
        // The board itself is untouched — every tap was blocked.
        expect(cubit.state.board!.arrowCount, 2);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_not_yet_defeat_before_maxMistakes_is_reached',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        for (var i = 0; i < CubeMangoScoring.maxMistakes - 1; i++) {
          cubit.tapArrow('a');
        }
      },
      verify: (cubit) {
        expect(cubit.state.mistakes, CubeMangoScoring.maxMistakes - 1);
        expect(cubit.state.status, Cube3DStatus.playing);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_clear_lastBlockedId_when_clearBlockedFlash_is_called',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('a');
        cubit.clearBlockedFlash();
      },
      verify: (cubit) => expect(cubit.state.lastBlockedId, isNull),
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_ignore_taps_on_an_unknown_arrow_id',
      build: () => _buildCubit(width: 2, height: 1, depth: 1),
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tapArrow('does-not-exist');
      },
      verify: (cubit) {
        expect(cubit.state.status, Cube3DStatus.playing);
        expect(cubit.state.board!.arrowCount, 2);
        expect(cubit.state.moveCount, 0, reason: 'a no-op tap is not a real attempt');
        expect(cubit.state.lastBlockedId, isNull);
      },
    );

    blocTest<Cube3DGameCubit, Cube3DGameState>(
      'should_advance_elapsedSeconds_on_tick',
      build: () {
        final clock = _FakeClock(2000000);
        return _buildCubit(width: 2, height: 1, depth: 1, clock: clock.call);
      },
      act: (cubit) {
        cubit.load(_levelOf([arrowA, arrowB], width: 2, height: 1, depth: 1));
        cubit.tick();
      },
      verify: (cubit) {
        // Same instant as load(): elapsed stays 0, and `tick()` must be a
        // no-op (skip-equal-value) rather than emitting a duplicate state.
        expect(cubit.state.elapsedSeconds, 0);
      },
    );
  });
}
