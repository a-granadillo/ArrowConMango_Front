import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

import '../../../domain/entities/arrow_entity.dart';
import '../../../domain/entities/spatial_direction.dart';
import '../../../data/topologies/grid_3d_topology.dart';
import 'cube3d_projection.dart';

/// Raw (x, y, z) offsets per [SpatialDirection], matching the domain
/// convention in `LevelGenerator3D`/`Grid3DGraph` (down = +y, back = +z).
const Map<SpatialDirection, (int, int, int)> _rawOffsets = {
  SpatialDirection.up: (0, -1, 0),
  SpatialDirection.down: (0, 1, 0),
  SpatialDirection.left: (-1, 0, 0),
  SpatialDirection.right: (1, 0, 0),
  SpatialDirection.fwd: (0, 0, -1),
  SpatialDirection.back: (0, 0, 1),
};

const double _halfExtent = 0.42;

/// How far (in model units) a cubelet slides along its direction while
/// exiting, and how much it nudges when blocked.
const double _exitTravel = 3.2;
const double _bumpAmplitude = 0.22;

const Color _dangerRed = Color(0xFFE85D5D);

// Corner index bit layout: bit0=x(0=-h,1=+h), bit1=y(0=-h,1=+h), bit2=z(0=-h,1=+h).
const List<int> _faceNegX = [0, 2, 6, 4];
const List<int> _facePosX = [1, 3, 7, 5];
const List<int> _faceNegY = [0, 1, 5, 4];
const List<int> _facePosY = [2, 3, 7, 6];
const List<int> _faceNegZ = [0, 1, 3, 2];
const List<int> _facePosZ = [4, 5, 7, 6];

/// An arrow that just exited, still rendered mid-flight for one animation.
class ExitingCubelet {
  const ExitingCubelet({required this.arrow, required this.progress});

  final ArrowEntity arrow;

  /// 0 → still in place, 1 → fully flown off and invisible.
  final double progress;
}

/// Paints the rotatable "Tap Away"-style cube: one shaded 3D cubelet per
/// single-cell [ArrowEntity], sorted back-to-front (painter's algorithm),
/// each with a direction glyph pointing toward its [SpatialDirection].
///
/// Draws a dark dotted backdrop (matching [BoardSurfacePainter]'s look) so
/// the bright arrow palette reads clearly regardless of rotation.
class CubeBoardPainter extends CustomPainter {
  CubeBoardPainter({
    required this.arrows,
    required this.width,
    required this.height,
    required this.depth,
    required this.rotation,
    required this.colorOf,
    this.exiting = const [],
    this.bumpingId,
    this.bumpProgress = 0.0,
  });

  final List<ArrowEntity> arrows;
  final int width;
  final int height;
  final int depth;
  final vm.Matrix4 rotation;
  final Color Function(String id) colorOf;

  /// Arrows that just succeeded and are flying off, kept alive for one
  /// animation cycle after being removed from [arrows].
  final List<ExitingCubelet> exiting;

  /// Arrow that was just tapped but is blocked — nudges and flashes red.
  final String? bumpingId;

  /// 0 → start of the bump, 1 → end (envelope peaks at the midpoint).
  final double bumpProgress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackdrop(canvas, size);
    if (arrows.isEmpty && exiting.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDim = [width, height, depth].reduce(math.max).toDouble();
    final cellSize = size.shortestSide * 0.62 / maxDim;
    final cameraDistance = maxDim * 1.7;

    final drawables = <_DrawableCubelet>[];

    for (final arrow in arrows) {
      final bumping = arrow.id == bumpingId;
      final envelope = bumping ? math.sin(bumpProgress.clamp(0.0, 1.0) * math.pi) : 0.0;
      final displacement = bumping
          ? _modelDeltaFor(arrow.direction as SpatialDirection) * (_bumpAmplitude * envelope)
          : vm.Vector3.zero();

      drawables.add(
        _buildDrawable(
          arrow,
          center: center,
          cellSize: cellSize,
          cameraDistance: cameraDistance,
          displacement: displacement,
          opacity: 1.0,
          redBlend: envelope,
        ),
      );
    }

    for (final ex in exiting) {
      final progress = ex.progress.clamp(0.0, 1.0);
      final displacement =
          _modelDeltaFor(ex.arrow.direction as SpatialDirection) * (_exitTravel * progress);

      drawables.add(
        _buildDrawable(
          ex.arrow,
          center: center,
          cellSize: cellSize,
          cameraDistance: cameraDistance,
          displacement: displacement,
          opacity: 1.0 - progress,
          redBlend: 0.0,
        ),
      );
    }

    drawables.sort((a, b) => b.avgDepth.compareTo(a.avgDepth));

    for (final d in drawables) {
      _paintCubelet(canvas, d, colorOf(d.id));
    }
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2A1D14),
    );

    final dotPaint = Paint()..color = const Color(0x1CFFF8EE);
    const spacing = 28.0;
    final dotRadius = spacing * 0.05;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  _DrawableCubelet _buildDrawable(
    ArrowEntity arrow, {
    required Offset center,
    required double cellSize,
    required double cameraDistance,
    required vm.Vector3 displacement,
    required double opacity,
    required double redBlend,
  }) {
    final node = arrow.occupiedNodes.single as Cube3DNodeId;
    // Flip the row axis only: the domain's "down" increases y, but the
    // shared projection utility assumes a conventional Y-up world.
    final base = Cube3DProjection.cellToModel(
          node.x,
          height - 1 - node.y,
          node.z,
          width,
          height,
          depth,
        ) +
        displacement;

    final corners = _corners(base);
    final projectedCorners = corners
        .map(
          (c) => Cube3DProjection.project(
            c,
            rotation,
            cellSize: cellSize,
            cameraDistance: cameraDistance,
            center: center,
          ),
        )
        .toList(growable: false);

    var avgDepth = 0.0;
    var nearIdx = 0;
    for (var i = 0; i < 8; i++) {
      avgDepth += projectedCorners[i].depth;
      if (projectedCorners[i].depth < projectedCorners[nearIdx].depth) {
        nearIdx = i;
      }
    }
    avgDepth /= 8;

    final centerProj = Cube3DProjection.project(
      base,
      rotation,
      cellSize: cellSize,
      cameraDistance: cameraDistance,
      center: center,
    );
    final tip =
        base + _modelDeltaFor(arrow.direction as SpatialDirection) * (_halfExtent + 0.45);
    final tipProj = Cube3DProjection.project(
      tip,
      rotation,
      cellSize: cellSize,
      cameraDistance: cameraDistance,
      center: center,
    );

    return _DrawableCubelet(
      id: arrow.id,
      corners: projectedCorners,
      nearCornerIndex: nearIdx,
      avgDepth: avgDepth,
      center: centerProj.screen,
      tip: tipProj.screen,
      opacity: opacity,
      redBlend: redBlend,
    );
  }

  void _paintCubelet(Canvas canvas, _DrawableCubelet d, Color baseColor) {
    if (d.opacity <= 0.0) return;
    final color = d.redBlend > 0
        ? Color.lerp(baseColor, _dangerRed, d.redBlend)!
        : baseColor;
    final bit0 = d.nearCornerIndex & 1;
    final bit1 = (d.nearCornerIndex >> 1) & 1;
    final bit2 = (d.nearCornerIndex >> 2) & 1;

    final faces = [
      (bit0 == 0 ? _faceNegX : _facePosX, 0.85),
      (bit1 == 0 ? _faceNegY : _facePosY, 1.15),
      (bit2 == 0 ? _faceNegZ : _facePosZ, 0.6),
    ];

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF000000).withValues(alpha: 0.25 * d.opacity);

    for (final (indices, factor) in faces) {
      final path = Path()
        ..moveTo(d.corners[indices[0]].screen.dx, d.corners[indices[0]].screen.dy);
      for (var i = 1; i < indices.length; i++) {
        path.lineTo(d.corners[indices[i]].screen.dx, d.corners[indices[i]].screen.dy);
      }
      path.close();

      final shaded = _shade(color, factor);
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..color = shaded.withValues(alpha: shaded.a * d.opacity);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, outline);
    }

    _drawArrowGlyph(canvas, d.center, d.tip, d.opacity);
  }

  void _drawArrowGlyph(Canvas canvas, Offset from, Offset to, double opacity) {
    final glyphColor = const Color(0xE6FFF8EE).withValues(
      alpha: const Color(0xE6FFF8EE).a * opacity,
    );

    final hub = Paint()
      ..style = PaintingStyle.fill
      ..color = glyphColor;
    canvas.drawCircle(from, 3.2, hub);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = glyphColor;
    canvas.drawLine(from, to, line);

    final dir = to - from;
    final len = dir.distance;
    if (len < 1e-6) return;
    final unit = dir / len;
    final normal = Offset(-unit.dy, unit.dx);
    const headLen = 7.0;
    const headWidth = 5.0;
    final tipBack = to - unit * headLen;
    final p1 = tipBack + normal * headWidth;
    final p2 = tipBack - normal * headWidth;
    final headPath = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(
      headPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = glyphColor,
    );
  }

  static Color _shade(Color base, double factor) {
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 0.92)).toColor();
  }

  static List<vm.Vector3> _corners(vm.Vector3 c) {
    const h = _halfExtent;
    return [
      vm.Vector3(c.x - h, c.y - h, c.z - h),
      vm.Vector3(c.x + h, c.y - h, c.z - h),
      vm.Vector3(c.x - h, c.y + h, c.z - h),
      vm.Vector3(c.x + h, c.y + h, c.z - h),
      vm.Vector3(c.x - h, c.y - h, c.z + h),
      vm.Vector3(c.x + h, c.y - h, c.z + h),
      vm.Vector3(c.x - h, c.y + h, c.z + h),
      vm.Vector3(c.x + h, c.y + h, c.z + h),
    ];
  }

  static vm.Vector3 _modelDeltaFor(SpatialDirection direction) {
    final offset = _rawOffsets[direction]!;
    // Y flip mirrors the row-axis flip applied to cell positions above.
    return vm.Vector3(
      offset.$1.toDouble(),
      -offset.$2.toDouble(),
      offset.$3.toDouble(),
    );
  }

  @override
  bool shouldRepaint(covariant CubeBoardPainter oldDelegate) {
    return !listEquals(oldDelegate.arrows, arrows) ||
        oldDelegate.rotation != rotation ||
        oldDelegate.bumpingId != bumpingId ||
        oldDelegate.bumpProgress != bumpProgress ||
        oldDelegate.exiting.length != exiting.length ||
        !_exitingUnchanged(oldDelegate.exiting, exiting);
  }

  static bool _exitingUnchanged(List<ExitingCubelet> a, List<ExitingCubelet> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i].arrow.id != b[i].arrow.id || a[i].progress != b[i].progress) return false;
    }
    return true;
  }
}

class _DrawableCubelet {
  const _DrawableCubelet({
    required this.id,
    required this.corners,
    required this.nearCornerIndex,
    required this.avgDepth,
    required this.center,
    required this.tip,
    required this.opacity,
    required this.redBlend,
  });

  final String id;
  final List<Projected> corners;
  final int nearCornerIndex;
  final double avgDepth;
  final Offset center;
  final Offset tip;
  final double opacity;
  final double redBlend;
}
