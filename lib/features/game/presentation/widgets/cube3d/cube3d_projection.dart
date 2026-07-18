import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' as vm;

/// A point projected to the screen, carrying its camera-space [depth] for
/// painter's-algorithm sorting. Larger [depth] means farther from the camera.
class Projected {
  const Projected(this.screen, this.depth);
  final Offset screen;
  final double depth;
}

/// Pure, unit-testable 3D→2D projection for the rotatable cube UI.
///
/// No widget/painting dependencies — safe to unit test directly. Model space
/// places the cube's center at the origin; [cellToModel] converts a discrete
/// cell index into that centered space.
abstract final class Cube3DProjection {
  /// Converts a 0-based cell index into centered model space, so a
  /// `width×height×depth` cube spans `[-(n-1)/2, (n-1)/2]` on each axis.
  static vm.Vector3 cellToModel(
    int x,
    int y,
    int z,
    int width,
    int height,
    int depth,
  ) {
    return vm.Vector3(
      x - (width - 1) / 2,
      y - (height - 1) / 2,
      z - (depth - 1) / 2,
    );
  }

  /// Builds the combined orbit rotation from [yaw] (around Y) and [pitch]
  /// (around X), both in radians.
  static vm.Matrix4 rotationFor(double yaw, double pitch) {
    return vm.Matrix4.rotationY(yaw) * vm.Matrix4.rotationX(pitch);
  }

  /// Projects a point in centered model space to screen coordinates.
  ///
  /// [rotation] orients the cube (see [rotationFor]); [cellSize] scales one
  /// model unit to pixels at the origin; [cameraDistance] controls
  /// perspective strength (larger = flatter, more orthographic); [center] is
  /// the screen-space origin (usually the canvas center).
  static Projected project(
    vm.Vector3 modelPoint,
    vm.Matrix4 rotation, {
    required double cellSize,
    required double cameraDistance,
    required Offset center,
  }) {
    final rotated = rotation.transform3(vm.Vector3.copy(modelPoint));
    final depth = cameraDistance + rotated.z;
    final scale = cameraDistance / depth;
    final screen = Offset(
      center.dx + rotated.x * cellSize * scale,
      center.dy - rotated.y * cellSize * scale,
    );
    return Projected(screen, depth);
  }
}
