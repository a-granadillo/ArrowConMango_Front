import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/data/topologies/grid_2d_topology.dart';
import 'package:arrowconmango_front/features/game/domain/entities/cardinal_direction.dart';
import 'package:arrowconmango_front/features/game/domain/errors/overlapping_arrows_failure.dart';
import 'package:arrowconmango_front/features/game/domain/services/level_builder.dart';

void main() {
  group('LevelBuilder', () {
    Grid2DNodeId node(int row, int col) => Grid2DNodeId(row: row, col: col);

    test('should_build_level_with_single_arrow', () {
      // Arrange
      final builder = LevelBuilder()..levelId = 1;

      // Act
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0)],
        direction: CardinalDirection.right,
      );
      final level = builder.build();

      // Assert
      expect(level.levelId, equals(1));
      expect(level.templateBoard.arrowCount, equals(1));
      expect(level.templateBoard.getArrowById('a1'), isNotNull);
    });

    test('should_build_level_with_multiple_arrows', () {
      // Arrange
      final builder = LevelBuilder()..levelId = 5;

      // Act
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0)],
        direction: CardinalDirection.right,
      );
      builder.addArrow(
        id: 'a2',
        nodes: [node(2, 1), node(2, 2)],
        direction: CardinalDirection.down,
      );
      final level = builder.build();

      // Assert
      expect(level.levelId, equals(5));
      expect(level.templateBoard.arrowCount, equals(2));
      expect(level.templateBoard.getArrowById('a1'), isNotNull);
      expect(level.templateBoard.getArrowById('a2'), isNotNull);
    });

    test('should_throw_when_levelId_not_set', () {
      // Arrange
      final builder = LevelBuilder();
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0)],
        direction: CardinalDirection.right,
      );

      // Act / Assert
      expect(() => builder.build(), throwsA(isA<StateError>()));
    });

    test('should_throw_when_arrows_overlap', () {
      // Arrange
      final builder = LevelBuilder()..levelId = 1;
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0), node(0, 1)],
        direction: CardinalDirection.right,
      );
      builder.addArrow(
        id: 'a2',
        nodes: [node(0, 1), node(0, 2)],
        direction: CardinalDirection.down,
      );

      // Act / Assert
      expect(
        () => builder.build(),
        throwsA(isA<OverlappingArrowsFailure>()),
      );
    });

    test('should_reset_builder_state', () {
      // Arrange
      final builder = LevelBuilder()..levelId = 1;
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0)],
        direction: CardinalDirection.right,
      );

      // Act
      builder.reset();
      builder.levelId = 2;
      builder.addArrow(
        id: 'b1',
        nodes: [node(1, 1)],
        direction: CardinalDirection.up,
      );
      final level = builder.build();

      // Assert
      expect(level.levelId, equals(2));
      expect(level.templateBoard.arrowCount, equals(1));
      expect(level.templateBoard.getArrowById('b1'), isNotNull);
      expect(level.templateBoard.getArrowById('a1'), isNull);
    });

    test('should_return_correct_difficulty_for_level_ranges', () {
      // Arrange & Act
      final easy = (LevelBuilder()..levelId = 3).build();
      final medium = (LevelBuilder()..levelId = 8).build();
      final hard = (LevelBuilder()..levelId = 12).build();

      // Assert
      expect(easy.difficulty(), equals('Easy'));
      expect(medium.difficulty(), equals('Medium'));
      expect(hard.difficulty(), equals('Hard'));
    });

    test('should_create_GameSession_from_template_board', () {
      // Arrange
      final builder = LevelBuilder()..levelId = 1;
      builder.addArrow(
        id: 'a1',
        nodes: [node(0, 0)],
        direction: CardinalDirection.right,
      );
      final level = builder.build();

      // Act
      final session = level.startSession(
        sessionId: 'test-session-123',
        startedAtMs: 1234567890,
      );

      // Assert
      expect(session.sessionId, equals('test-session-123'));
      expect(session.startedAtMs, equals(1234567890));
      expect(session.boardState.arrowCount, equals(1));
      expect(session.boardState.getArrowById('a1'), isNotNull);
      expect(session.moveCount, equals(0));
    });
  });
}
