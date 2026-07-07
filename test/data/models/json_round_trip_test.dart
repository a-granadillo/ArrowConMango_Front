import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/arrow_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_size_model.dart';
import 'package:arrowconmango_front/features/game/data/models/board_state_model.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';
import 'package:arrowconmango_front/features/game/data/models/node_model.dart';
import 'package:test/test.dart';

/// JSON round-trip tests for all data models.
///
/// These tests verify that `toJson()` → `fromJson()` preserves data integrity
/// for each serializable model, catching schema regressions like missing keys,
/// type casts, or optional field handling.
void main() {
  group('NodeModel JSON round-trip', () {
    test('should_preserve_row_and_col_through_serialization', () {
      // Arrange
      const original = NodeModel(row: 3, col: 7);

      // Act
      final json = original.toJson();
      final restored = NodeModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(json['row'], equals(3));
      expect(json['col'], equals(7));
    });

    test('should_handle_zero_coordinates', () {
      // Arrange
      const original = NodeModel(row: 0, col: 0);

      // Act
      final restored = NodeModel.fromJson(original.toJson());

      // Assert
      expect(restored, equals(original));
    });
  });

  group('BoardStateModel JSON round-trip', () {
    test('should_preserve_arrows_list_through_serialization', () {
      // Arrange
      const original = BoardStateModel(
        arrows: [
          ArrowModel(
            id: 'a1',
            direction: 'right',
            nodes: [NodeModel(row: 0, col: 0), NodeModel(row: 0, col: 1)],
          ),
          ArrowModel(
            id: 'a2',
            direction: 'down',
            nodes: [NodeModel(row: 1, col: 2)],
          ),
        ],
      );

      // Act
      final json = original.toJson();
      final restored = BoardStateModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(restored.arrows.length, equals(2));
    });

    test('should_handle_empty_arrows_list', () {
      // Arrange
      const original = BoardStateModel(arrows: []);

      // Act
      final restored = BoardStateModel.fromJson(original.toJson());

      // Assert
      expect(restored, equals(original));
      expect(restored.arrows, isEmpty);
    });
  });

  group('LevelModel JSON round-trip', () {
    test('should_preserve_all_fields_through_serialization', () {
      // Arrange
      const original = LevelModel(
        id: 5,
        name: 'Level 5',
        difficulty: 'Medium',
        boardSize: BoardSizeModel(rows: 4, cols: 5),
        boardState: BoardStateModel(
          arrows: [
            ArrowModel(
              id: 'arrow-x',
              direction: 'up',
              nodes: [NodeModel(row: 2, col: 3)],
            ),
          ],
        ),
      );

      // Act
      final json = original.toJson();
      final restored = LevelModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(json['id'], equals(5));
      expect(json['name'], equals('Level 5'));
      expect(json['difficulty'], equals('Medium'));
      expect(json['boardSize'], equals({'rows': 4, 'cols': 5}));
    });
  });

  group('AppProgressModel JSON round-trip', () {
    test('should_preserve_all_fields_with_scores', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 3,
        completedLevels: [1, 2],
        scores: {'1': 950, '2': 800},
      );

      // Act
      final json = original.toJson();
      final restored = AppProgressModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(restored.scores, equals({'1': 950, '2': 800}));
    });

    test('should_omit_scores_when_null', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 1,
        completedLevels: [],
        scores: null,
      );

      // Act
      final json = original.toJson();
      final restored = AppProgressModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(json.containsKey('scores'), isFalse);
      expect(restored.scores, isNull);
    });

    test('should_handle_empty_scores_map', () {
      // Arrange
      const original = AppProgressModel(
        currentLevel: 2,
        completedLevels: [1],
        scores: {},
      );

      // Act
      final json = original.toJson();
      final restored = AppProgressModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
      expect(restored.scores, isEmpty);
    });
  });
}
