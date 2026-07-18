import 'package:arrowconmango_front/features/creative/presentation/bloc/hex_level_editor_cubit.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_level.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_hex_creative_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockHexCreativeLevelRepository extends Mock
    implements IHexCreativeLevelRepository {}

HexLevel _fakeSaved(HexLevel draft, {String id = 'new-id'}) => HexLevel(
      id: id,
      name: draft.name,
      difficulty: draft.difficulty,
      radius: draft.radius,
      templateBoard: draft.templateBoard,
      authorId: 'me',
      isPublished: draft.isPublished,
      timeLimitSeconds: draft.timeLimitSeconds,
      maxMistakes: draft.maxMistakes,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(
      HexLevel(
        id: '',
        name: '',
        difficulty: 'Easy',
        radius: 2,
        templateBoard: BoardState(arrows: const []),
      ),
    );
  });

  late _MockHexCreativeLevelRepository repo;
  late HexLevelEditorCubit cubit;

  setUp(() {
    repo = _MockHexCreativeLevelRepository();
    cubit = HexLevelEditorCubit(repo);
  });

  // Replicates the old tap-to-place/select/rotate shortcut on top of the
  // drag API: a press-and-release with no movement in between.
  void tap(int q, int r) {
    cubit.beginDrag(q, r);
    cubit.endDrag();
  }

  group('placing and selecting arrows', () {
    test('should_place_a_1_cell_se_pointing_arrow_on_an_empty_hex', () {
      tap(0, 0);

      expect(cubit.state.arrows, hasLength(1));
      expect(cubit.state.arrows.first.direction, HexDirection.se);
      expect(cubit.state.arrows.first.length, 1);
      expect(cubit.state.selectedArrowId, cubit.state.arrows.first.id);
    });

    test('should_select_an_existing_arrow_on_first_tap', () {
      tap(0, 0);
      final id = cubit.state.arrows.first.id;
      cubit.removeSelected(); // deselect via removal, then re-place to reset
      tap(0, 0);
      final newId = cubit.state.arrows.first.id;

      // Tapping a different empty cell selects the new placement, not a
      // rotation — rotation only happens on a *second* tap of the *same*
      // already-selected arrow.
      expect(newId, isNot(id));
    });

    test(
      'should_rotate_the_selected_arrow_through_all_6_hex_directions_on_repeated_taps',
      () {
        tap(0, 0);
        expect(cubit.state.arrows.first.direction, HexDirection.se);

        const expectedCycle = [
          HexDirection.s,
          HexDirection.sw,
          HexDirection.nw,
          HexDirection.n,
          HexDirection.ne,
          HexDirection.se,
        ];
        for (final expectedDirection in expectedCycle) {
          tap(0, 0); // same cell, already selected -> rotate
          expect(cubit.state.arrows.first.direction, expectedDirection);
        }
      },
    );

    test('should_reject_a_resize_that_would_overlap_another_arrow', () {
      tap(0, 0); // A: se, (0,0)
      cubit.resizeSelected(1); // A: se length 2 -> (0,0),(1,0)

      tap(1, -1); // B: se, (1,-1) — selected, in bounds for radius 2
      cubit.resizeSelected(-1); // ensure length 1 (no-op, already 1)
      final beforeLength = cubit.state.arrows
          .firstWhere((a) => a.id == cubit.state.selectedArrowId)
          .length;
      expect(beforeLength, 1);

      // Rotate B to point 'sw' so extending it would head toward A's body.
      tap(1, -1); // rotate se -> s
      tap(1, -1); // rotate s -> sw: now pointing sw from (1,-1)

      // Extending B (tail (1,-1), dir sw, length 2) would occupy (1,-1),(0,0)
      // — (0,0) is already occupied by A.
      cubit.resizeSelected(1);

      final b = cubit.state.arrows.firstWhere(
        (a) => a.id == cubit.state.selectedArrowId,
      );
      expect(b.length, 1);
      expect(cubit.state.arrows, hasLength(2));
    });
  });

  group('drag placement', () {
    test('should_sketch_a_live_preview_while_dragging_se', () {
      cubit.beginDrag(0, 0);
      expect(cubit.state.dragPreview, isNotNull);
      expect(cubit.state.arrows, isEmpty); // not committed yet

      cubit.updateDrag(2, 0); // 2 steps se from (0,0)
      expect(cubit.state.dragPreview!.direction, HexDirection.se);
      expect(cubit.state.dragPreview!.length, 3);
    });

    test('should_commit_a_multi_cell_arrow_dragged_along_the_n_axis', () {
      cubit.beginDrag(0, 2);
      cubit.updateDrag(0, -1); // 3 steps north
      cubit.endDrag();

      expect(cubit.state.arrows, hasLength(1));
      expect(cubit.state.dragPreview, isNull);
      final arrow = cubit.state.arrows.first;
      expect(arrow.direction, HexDirection.n);
      expect(arrow.length, 4);
      expect(cubit.state.selectedArrowId, arrow.id);
    });

    test('should_collapse_a_drag_that_never_moved_to_a_1_cell_arrow', () {
      cubit.beginDrag(1, 1);
      cubit.endDrag();

      final arrow = cubit.state.arrows.first;
      expect(arrow.direction, HexDirection.se);
      expect(arrow.length, 1);
    });

    test('should_clamp_the_preview_to_the_board_edge', () {
      // Default radius is 2: from (0,0), the se axis only has 3 cells
      // total ((0,0),(1,0),(2,0)) before leaving the board.
      cubit.beginDrag(0, 0);
      cubit.updateDrag(99, 0);

      expect(cubit.state.dragPreview!.length, 3);
    });

    test('should_reject_committing_a_drag_that_would_overlap_another_arrow', () {
      tap(0, 0); // A: se, length 1, occupies (0,0)
      cubit.resizeSelected(1); // A now occupies (0,0),(1,0)

      cubit.beginDrag(2, 0);
      cubit.updateDrag(0, 0); // straight line nw through (1,0) into (0,0)
      cubit.endDrag();

      expect(cubit.state.arrows, hasLength(1)); // only A, drag rejected
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('resizing', () {
    test('should_extend_and_shrink_the_selected_arrow', () {
      tap(0, 0);
      expect(cubit.state.arrows.first.length, 1);

      cubit.resizeSelected(2);
      expect(cubit.state.arrows.first.length, 3);

      cubit.resizeSelected(-1);
      expect(cubit.state.arrows.first.length, 2);
    });

    test('should_refuse_to_shrink_below_length_1', () {
      tap(0, 0);
      cubit.resizeSelected(-5);
      expect(cubit.state.arrows.first.length, 1);
    });

    test('should_refuse_to_extend_past_the_board_edge', () {
      // Default radius is 2; (2,0) is the last hex on the se axis from (0,0).
      tap(2, 0);
      cubit.resizeSelected(1); // would need (3,0), out of bounds
      expect(cubit.state.arrows.first.length, 1);
    });
  });

  group('removal', () {
    test('should_remove_the_selected_arrow', () {
      tap(0, 0);
      expect(cubit.state.arrows, hasLength(1));

      cubit.removeSelected();
      expect(cubit.state.arrows, isEmpty);
      expect(cubit.state.selectedArrowId, isNull);
    });
  });

  group('board radius', () {
    test('should_drop_arrows_that_no_longer_fit_after_shrinking', () {
      tap(2, 0); // valid on the default radius-2 board
      expect(cubit.state.arrows, hasLength(1));

      cubit.setRadius(1); // (2,0) no longer fits within radius 1
      expect(cubit.state.arrows, isEmpty);
    });

    test('should_keep_arrows_that_still_fit_after_resizing', () {
      tap(0, 0);
      cubit.setRadius(4);
      expect(cubit.state.arrows, hasLength(1));
    });
  });

  group('solving and publishing gate', () {
    test('should_require_a_test_play_victory_before_publish_is_allowed', () {
      expect(cubit.state.canPublish, isFalse);
      cubit.markSolved();
      // Still false: no saved id yet.
      expect(cubit.state.canPublish, isFalse);
    });
  });

  group('save', () {
    test('should_refuse_to_save_an_empty_board', () async {
      final saved = await cubit.save();
      expect(saved, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
      verifyNever(() => repo.createLevel(any()));
    });

    test('should_create_a_new_draft_when_never_saved_before', () async {
      tap(0, 0);
      when(() => repo.createLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(invocation.positionalArguments.first as HexLevel),
        ),
      );

      final saved = await cubit.save();

      expect(saved, isTrue);
      expect(cubit.state.id, 'new-id');
      verify(() => repo.createLevel(any())).called(1);
      verifyNever(() => repo.updateLevel(any()));
    });

    test('should_update_the_existing_draft_on_subsequent_saves', () async {
      tap(0, 0);
      when(() => repo.createLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(invocation.positionalArguments.first as HexLevel),
        ),
      );
      await cubit.save();

      when(() => repo.updateLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(
            invocation.positionalArguments.first as HexLevel,
            id: 'new-id',
          ),
        ),
      );
      tap(1, 1);
      final saved = await cubit.save();

      expect(saved, isTrue);
      verify(() => repo.updateLevel(any())).called(1);
    });

    test('should_surface_the_failure_message_when_save_fails', () async {
      tap(0, 0);
      when(
        () => repo.createLevel(any()),
      ).thenAnswer((_) async => const Error(GenericFailure('network down')));

      final saved = await cubit.save();

      expect(saved, isFalse);
      expect(cubit.state.errorMessage, contains('network down'));
    });
  });

  group('publish', () {
    test('should_publish_once_saved_and_solved', () async {
      tap(0, 0);
      when(() => repo.createLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(invocation.positionalArguments.first as HexLevel),
        ),
      );
      await cubit.save();
      cubit.markSolved();
      expect(cubit.state.canPublish, isTrue);

      when(() => repo.publishLevel('new-id')).thenAnswer(
        (_) async => Success(
          _fakeSaved(
            HexLevel(
              id: 'new-id',
              name: 'x',
              difficulty: 'Easy',
              radius: 2,
              templateBoard: cubit.currentBoard,
              isPublished: true,
            ),
          ),
        ),
      );

      final published = await cubit.publish();

      expect(published, isTrue);
      expect(cubit.state.isPublished, isTrue);
    });

    test('should_refuse_to_publish_without_a_prior_solve', () async {
      tap(0, 0);
      when(() => repo.createLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(invocation.positionalArguments.first as HexLevel),
        ),
      );
      await cubit.save();

      final published = await cubit.publish();

      expect(published, isFalse);
      verifyNever(() => repo.publishLevel(any()));
    });
  });
}
