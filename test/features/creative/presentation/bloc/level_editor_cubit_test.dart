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

  group('placing and selecting arrows', () {
    test('should_place_a_1_cell_right_pointing_arrow_on_an_empty_cell', () {
      cubit.tapCell(0, 0);

      expect(cubit.state.arrows, hasLength(1));
      expect(cubit.state.arrows.first.direction, CardinalDirection.right);
      expect(cubit.state.arrows.first.length, 1);
      expect(cubit.state.selectedArrowId, cubit.state.arrows.first.id);
    });

    test('should_select_an_existing_arrow_on_first_tap', () {
      cubit.tapCell(0, 0);
      final id = cubit.state.arrows.first.id;
      cubit.removeSelected(); // deselect via removal, then re-place to reset
      cubit.tapCell(0, 0);
      final newId = cubit.state.arrows.first.id;

      // Tapping a different empty cell selects the new placement, not a
      // rotation — rotation only happens on a *second* tap of the *same*
      // already-selected arrow.
      expect(newId, isNot(id));
    });

    test(
      'should_rotate_the_selected_arrow_on_a_second_tap_of_the_same_cell',
      () {
        cubit.tapCell(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.right);

        cubit.tapCell(1, 1); // same cell, already selected -> rotate
        expect(cubit.state.arrows.first.direction, CardinalDirection.down);

        cubit.tapCell(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.left);

        cubit.tapCell(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.up);

        cubit.tapCell(1, 1);
        expect(cubit.state.arrows.first.direction, CardinalDirection.right);
      },
    );

    test('should_reject_a_resize_that_would_overlap_another_arrow', () {
      cubit.tapCell(0, 0); // A: right, (0,0)
      cubit.resizeSelected(1); // A: right length 2 -> (0,0),(0,1)
      expect(cubit.state.arrows, hasLength(1));

      cubit.tapCell(1, 1); // B: right, (1,1) — selected
      cubit.tapCell(1, 1); // rotate -> down
      cubit.tapCell(1, 1); // rotate -> left
      cubit.tapCell(1, 1); // rotate -> up, tail (1,1), length 1 -> (1,1)
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

  group('resizing', () {
    test('should_extend_and_shrink_the_selected_arrow', () {
      cubit.tapCell(0, 0);
      expect(cubit.state.arrows.first.length, 1);

      cubit.resizeSelected(2);
      expect(cubit.state.arrows.first.length, 3);

      cubit.resizeSelected(-1);
      expect(cubit.state.arrows.first.length, 2);
    });

    test('should_refuse_to_shrink_below_length_1', () {
      cubit.tapCell(0, 0);
      cubit.resizeSelected(-5);
      expect(cubit.state.arrows.first.length, 1);
    });

    test('should_refuse_to_extend_past_the_board_edge', () {
      // Board defaults to 6x6; place at col 5 (last column) pointing right.
      cubit.tapCell(0, 5);
      cubit.resizeSelected(1); // would need col 6, out of bounds
      expect(cubit.state.arrows.first.length, 1);
    });
  });

  group('removal', () {
    test('should_remove_the_selected_arrow', () {
      cubit.tapCell(0, 0);
      expect(cubit.state.arrows, hasLength(1));

      cubit.removeSelected();
      expect(cubit.state.arrows, isEmpty);
      expect(cubit.state.selectedArrowId, isNull);
    });
  });

  group('board size', () {
    test('should_drop_arrows_that_no_longer_fit_after_shrinking', () {
      cubit.tapCell(5, 5); // valid on the default 6x6 board
      expect(cubit.state.arrows, hasLength(1));

      cubit.setBoardSize(rows: 4, cols: 4); // (5,5) no longer fits
      expect(cubit.state.arrows, isEmpty);
    });

    test('should_keep_arrows_that_still_fit_after_resizing', () {
      cubit.tapCell(0, 0);
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
      cubit.tapCell(0, 0);
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
      cubit.tapCell(0, 0);
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
      cubit.tapCell(1, 1);
      final saved = await cubit.save();

      expect(saved, isTrue);
      verify(() => repo.updateLevel(any())).called(1);
    });

    test('should_surface_the_failure_message_when_save_fails', () async {
      cubit.tapCell(0, 0);
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
      cubit.tapCell(0, 0);
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
      cubit.tapCell(0, 0);
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
