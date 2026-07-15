import 'package:test/test.dart';
import 'package:arrowconmango_front/features/game/domain/entities/board_geometry.dart';

void main() {
  group('BoardGeometry', () {
    group('BoardGeometry2D', () {
      test('should create valid instance when rows and cols are positive', () {
        // Arrange & Act
        const geometry = BoardGeometry2D(rows: 5, cols: 5);

        // Assert
        expect(geometry.rows, equals(5));
        expect(geometry.cols, equals(5));
      });

      test('should throw AssertionError when rows are non-positive', () {
        // Act & Assert
        expect(
          () => BoardGeometry2D(rows: 0, cols: 5),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => BoardGeometry2D(rows: -1, cols: 5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw AssertionError when cols are non-positive', () {
        // Act & Assert
        expect(
          () => BoardGeometry2D(rows: 5, cols: 0),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => BoardGeometry2D(rows: 5, cols: -2),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should support value equality', () {
        // Arrange
        const geom1 = BoardGeometry2D(rows: 4, cols: 4);
        const geom2 = BoardGeometry2D(rows: 4, cols: 4);
        const geom3 = BoardGeometry2D(rows: 3, cols: 4);

        // Assert
        expect(geom1, equals(geom2));
        expect(geom1, isNot(equals(geom3)));
        expect(geom1.hashCode, equals(geom2.hashCode));
      });
    });

    group('BoardGeometry3D', () {
      test('should create valid instance when rows, cols, and depth are positive', () {
        // Arrange & Act
        const geometry = BoardGeometry3D(rows: 3, cols: 4, depth: 5);

        // Assert
        expect(geometry.rows, equals(3));
        expect(geometry.cols, equals(4));
        expect(geometry.depth, equals(5));
      });

      test('should throw AssertionError when rows are non-positive', () {
        // Act & Assert
        expect(
          () => BoardGeometry3D(rows: 0, cols: 4, depth: 5),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => BoardGeometry3D(rows: -3, cols: 4, depth: 5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw AssertionError when cols are non-positive', () {
        // Act & Assert
        expect(
          () => BoardGeometry3D(rows: 3, cols: 0, depth: 5),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => BoardGeometry3D(rows: 3, cols: -1, depth: 5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should throw AssertionError when depth is non-positive', () {
        // Act & Assert
        expect(
          () => BoardGeometry3D(rows: 3, cols: 4, depth: 0),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => BoardGeometry3D(rows: 3, cols: 4, depth: -5),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should support value equality', () {
        // Arrange
        const geom1 = BoardGeometry3D(rows: 3, cols: 3, depth: 3);
        const geom2 = BoardGeometry3D(rows: 3, cols: 3, depth: 3);
        const geom3 = BoardGeometry3D(rows: 3, cols: 3, depth: 2);

        // Assert
        expect(geom1, equals(geom2));
        expect(geom1, isNot(equals(geom3)));
        expect(geom1.hashCode, equals(geom2.hashCode));
      });
    });
  });
}
