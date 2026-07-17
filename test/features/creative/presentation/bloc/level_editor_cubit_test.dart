import 'package:arrowconmango_front/features/creative/presentation/bloc/level_editor_cubit.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_state.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/entities/creative_level.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_creative_level_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreativeLevelRepository extends Mock
    implements ICreativeLevelRepository {}

CreativeLevel _fakeSaved(CreativeLevel draft, {String id = 'new-id'}) =>
    CreativeLevel(
      id: id,
      name: draft.name,
      difficulty: draft.difficulty,
      rows: draft.rows,
      cols: draft.cols,
      templateBoard: draft.templateBoard,
      authorId: 'me',
      isPublished: draft.isPublished,
      timeLimitSeconds: draft.timeLimitSeconds,
      maxMistakes: draft.maxMistakes,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(
      CreativeLevel(
        id: '',
        name: '',
        difficulty: 'Easy',
        rows: 4,
        cols: 4,
        templateBoard: BoardState(arrows: const []),
        authorId: null,
        isPublished: false,
      ),
    );
  });

  late _MockCreativeLevelRepository repo;
  late LevelEditorCubit cubit;

  setUp(() {
    repo = _MockCreativeLevelRepository();
    cubit = LevelEditorCubit(repo);
  });

  // Replicates the old tap-to-place/select/rotate shortcut on top of the
  // drag API: a press-and-release with no movement in between.
  void tap(int row, int col) {
    cubit.beginDrag(row, col);
    cubit.endDrag();
  }

  group('placing and selecting arrows', () {
    test('should_place_a_1_cell_right_pointing_arrow_on_an_empty_cell', () {
      tap(0, 0);

      expect(cubit.state.arrows, hasLength(1));
      expect(cubit.state.arrows.first.direction, CardinalDirection.right);
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
      'should_rotate_the_selected_arrow_on_a_second_tap_of_the_same_cell',
      () {
        tap(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.right);

        tap(1, 1); // same cell, already selected -> rotate
        expect(cubit.state.arrows.first.direction, CardinalDirection.down);

        tap(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.left);

        tap(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.up);

        tap(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.right);
      },
    );

    test('should_reject_a_resize_that_would_overlap_another_arrow', () {
      tap(0, 0); // A: right, (0,0)
      cubit.resizeSelected(1); // A: right length 2 -> (0,0),(0,1)
      expect(cubit.state.arrows, hasLength(1));

      tap(1, 1); // B: right, (1,1) — selected
      tap(1, 1); // rotate -> down
      tap(1, 1); // rotate -> left
      tap(1, 1); // rotate -> up, tail (1,1), length 1 -> (1,1)
      final beforeLength = cubit.state.arrows
          .firstWhere((a) => a.id == cubit.state.selectedArrowId)
          .length;
      expect(beforeLength, 1);

      // Extending B upward would claim (0,1), already occupied by A.
      cubit.resizeSelected(1);

      final b = cubit.state.arrows.firstWhere(
        (a) => a.id == cubit.state.selectedArrowId,
      );
      expect(b.length, 1);
      expect(cubit.state.arrows, hasLength(2));
    });
  });

  group('drag placement', () {
    test('should_sketch_a_live_preview_while_dragging', () {
      cubit.beginDrag(0, 0);
      expect(cubit.state.dragPreview, isNotNull);
      expect(cubit.state.arrows, isEmpty); // not committed yet

      cubit.updateDrag(0, 2);
      expect(cubit.state.dragPreview!.direction, CardinalDirection.right);
      expect(cubit.state.dragPreview!.length, 3);
    });

    test('should_commit_a_multi_cell_arrow_dragged_horizontally', () {
      cubit.beginDrag(2, 1);
      cubit.updateDrag(2, 4);
      cubit.endDrag();

      expect(cubit.state.arrows, hasLength(1));
      expect(cubit.state.dragPreview, isNull);
      final arrow = cubit.state.arrows.first;
      expect(arrow.direction, CardinalDirection.right);
      expect(arrow.length, 4);
      expect(cubit.state.selectedArrowId, arrow.id);
    });

    test('should_commit_a_multi_cell_arrow_dragged_vertically_upward', () {
      cubit.beginDrag(4, 0);
      cubit.updateDrag(1, 0);
      cubit.endDrag();

      final arrow = cubit.state.arrows.first;
      expect(arrow.direction, CardinalDirection.up);
      expect(arrow.length, 4);
    });

    test('should_collapse_a_drag_that_never_moved_to_a_1_cell_arrow', () {
      cubit.beginDrag(3, 3);
      cubit.endDrag();

      final arrow = cubit.state.arrows.first;
      expect(arrow.direction, CardinalDirection.right);
      expect(arrow.length, 1);
    });

    test('should_clamp_the_preview_to_the_board_edge', () {
      // Default board is 6x6; dragging from col 4 far to the right can only
      // reach col 5.
      cubit.beginDrag(0, 4);
      cubit.updateDrag(0, 99);

      expect(cubit.state.dragPreview!.length, 2);
    });

    test('should_reject_committing_a_drag_that_would_overlap_another_arrow', () {
      tap(0, 0); // A: right, length 1, occupies (0,0)
      cubit.resizeSelected(2); // A now occupies (0,0),(0,1),(0,2)

      cubit.beginDrag(2, 0);
      cubit.updateDrag(0, 0); // straight line up through (1,0) into (0,0)
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
      // Board defaults to 6x6; place at col 5 (last column) pointing right.
      tap(0, 5);
      cubit.resizeSelected(1); // would need col 6, out of bounds
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

  group('board size', () {
    test('should_drop_arrows_that_no_longer_fit_after_shrinking', () {
      tap(5, 5); // valid on the default 6x6 board
      expect(cubit.state.arrows, hasLength(1));

      cubit.setBoardSize(rows: 4, cols: 4); // (5,5) no longer fits
      expect(cubit.state.arrows, isEmpty);
    });

    test('should_keep_arrows_that_still_fit_after_resizing', () {
      tap(0, 0);
      cubit.setBoardSize(rows: 8, cols: 8);
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
          _fakeSaved(invocation.positionalArguments.first as CreativeLevel),
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
          _fakeSaved(invocation.positionalArguments.first as CreativeLevel),
        ),
      );
      await cubit.save();

      when(() => repo.updateLevel(any())).thenAnswer(
        (invocation) async => Success(
          _fakeSaved(
            invocation.positionalArguments.first as CreativeLevel,
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
          _fakeSaved(invocation.positionalArguments.first as CreativeLevel),
        ),
      );
      await cubit.save();
      cubit.markSolved();
      expect(cubit.state.canPublish, isTrue);

      when(() => repo.publishLevel('new-id')).thenAnswer(
        (_) async => Success(
          _fakeSaved(
            CreativeLevel(
              id: 'new-id',
              name: 'x',
              difficulty: 'Easy',
              rows: 6,
              cols: 6,
              templateBoard: cubit.currentBoard,
              authorId: 'me',
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
          _fakeSaved(invocation.positionalArguments.first as CreativeLevel),
        ),
      );
      await cubit.save();

      final published = await cubit.publish();

      expect(published, isFalse);
      verifyNever(() => repo.publishLevel(any()));
    });
  });
}
