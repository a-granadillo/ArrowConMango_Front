import 'package:arrowconmango_front/features/game/presentation/widgets/cube3d/cube3d_projection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() {
  group('Cube3DProjection.cellToModel', () {
    test('should_center_a_grid_around_the_origin', () {
      // Arrange / Act
      final model = Cube3DProjection.cellToModel(0, 0, 0, 3, 3, 3);

      // Assert: a 3-wide axis centers index 0 at -1.
      expect(model.x, -1.0);
      expect(model.y, -1.0);
      expect(model.z, -1.0);
    });

    test('should_place_the_middle_cell_at_the_origin_for_odd_extents', () {
      final model = Cube3DProjection.cellToModel(1, 1, 1, 3, 3, 3);
      expect(model.x, 0.0);
      expect(model.y, 0.0);
      expect(model.z, 0.0);
    });
  });

  group('Cube3DProjection.project', () {
    const center = Offset(200, 150);
    const cellSize = 40.0;
    const cameraDistance = 10.0;

    test('should_project_the_origin_to_the_screen_center_under_identity_rotation', () {
      // Arrange
      final identity = Cube3DProjection.rotationFor(0, 0);

      // Act
      final result = Cube3DProjection.project(
        vm.Vector3.zero(),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );

      // Assert
      expect(result.screen.dx, closeTo(center.dx, 1e-9));
      expect(result.screen.dy, closeTo(center.dy, 1e-9));
      expect(result.depth, closeTo(cameraDistance, 1e-9));
    });

    test('should_offset_screen_x_by_cellSize_when_point_is_right_of_origin_and_z_is_zero', () {
      final identity = Cube3DProjection.rotationFor(0, 0);

      final result = Cube3DProjection.project(
        vm.Vector3(1, 0, 0),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );

      // scale = cameraDistance / (cameraDistance + 0) == 1, so dx shifts by
      // exactly one cellSize.
      expect(result.screen.dx, closeTo(center.dx + cellSize, 1e-9));
      expect(result.screen.dy, closeTo(center.dy, 1e-9));
    });

    test('should_report_larger_depth_for_points_farther_along_z', () {
      final identity = Cube3DProjection.rotationFor(0, 0);

      final near = Cube3DProjection.project(
        vm.Vector3(0, 0, -2),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );
      final far = Cube3DProjection.project(
        vm.Vector3(0, 0, 2),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );

      expect(far.depth, greaterThan(near.depth));
    });

    test('should_shrink_apparent_scale_for_points_farther_from_the_camera', () {
      final identity = Cube3DProjection.rotationFor(0, 0);

      final near = Cube3DProjection.project(
        vm.Vector3(1, 0, -2),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );
      final far = Cube3DProjection.project(
        vm.Vector3(1, 0, 2),
        identity,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );

      // Both are offset from center in +x, but the nearer point should be
      // displaced farther on screen (larger apparent scale).
      expect(near.screen.dx - center.dx, greaterThan(far.screen.dx - center.dx));
    });
  });

  group('Cube3DProjection.rotationFor', () {
    test('should_preserve_vector_length_for_any_yaw_and_pitch', () {
      final rotation = Cube3DProjection.rotationFor(0.7, -1.1);
      final original = vm.Vector3(1, 2, 3);

      final rotated = rotation.transform3(vm.Vector3.copy(original));

      expect(rotated.length, closeTo(original.length, 1e-9));
    });

    test('should_leave_y_unchanged_for_a_yaw_only_rotation', () {
      // Yaw rotates around the Y axis, so a point's Y coordinate is
      // rotation-invariant regardless of the yaw angle.
      final rotation = Cube3DProjection.rotationFor(1.234, 0);
      final rotated = rotation.transform3(vm.Vector3(1, 5, -2));

      expect(rotated.y, closeTo(5, 1e-9));
    });

    test('should_return_the_original_vector_for_a_full_turn', () {
      final fullTurn = Cube3DProjection.rotationFor(
        2 * 3.14159265358979,
        2 * 3.14159265358979,
      );
      final original = vm.Vector3(1, -2, 3);

      final rotated = fullTurn.transform3(vm.Vector3.copy(original));

      expect(rotated.x, closeTo(original.x, 1e-6));
      expect(rotated.y, closeTo(original.y, 1e-6));
      expect(rotated.z, closeTo(original.z, 1e-6));
    });
  });
}
