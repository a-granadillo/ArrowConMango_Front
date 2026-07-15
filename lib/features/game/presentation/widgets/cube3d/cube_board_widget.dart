import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../data/topologies/grid_3d_topology.dart';
import '../../../domain/entities/arrow_entity.dart';
import 'cube3d_projection.dart';
import 'cube_board_painter.dart';

/// Free-orbit rotatable cube board — the "Tap Away"-style presentation.
///
/// Drag anywhere to orbit the cube (yaw + pitch); tap a cubelet to attempt to
/// slide its arrow out via [onArrowTap]. A tap is distinguished from a drag
/// by total pointer displacement, so rotating never misfires as a tap.
///
/// Arrows that disappear between rebuilds (a successful exit) keep animating
/// — sliding away and fading — for one cycle before being dropped; a tap on
/// [blockedId] triggers a quick nudge-and-flash "bump" on that cubelet.
class CubeBoardWidget extends StatefulWidget {
  const CubeBoardWidget({
    super.key,
    required this.arrows,
    required this.width,
    required this.height,
    required this.depth,
    required this.colorOf,
    this.onArrowTap,
    this.blockedId,
  });

  final List<ArrowEntity> arrows;
  final int width;
  final int height;
  final int depth;
  final Color Function(String id) colorOf;
  final void Function(String arrowId)? onArrowTap;

  /// Arrow that was just tapped but is blocked — bumped for feedback.
  final String? blockedId;

  @override
  State<CubeBoardWidget> createState() => _CubeBoardWidgetState();
}

class _CubeBoardWidgetState extends State<CubeBoardWidget>
    with TickerProviderStateMixin {
  double _yaw = -0.5;
  double _pitch = -0.35;
  Offset _dragAccum = Offset.zero;
  Offset _lastTapPosition = Offset.zero;

  static const double _dragToRadians = 0.01;
  static const double _tapDisplacementThreshold = 8.0;
  static const Duration _exitDuration = Duration(milliseconds: 420);
  static const Duration _bumpDuration = Duration(milliseconds: 360);

  final List<_ExitAnim> _exiting = [];

  AnimationController? _bumpController;
  String? _bumpingId;

  @override
  void didUpdateWidget(covariant CubeBoardWidget old) {
    super.didUpdateWidget(old);
    _syncExiting(old.arrows, widget.arrows);
    if (widget.blockedId != null && widget.blockedId != old.blockedId) {
      _startBump(widget.blockedId!);
    }
  }

  @override
  void dispose() {
    for (final anim in _exiting) {
      anim.controller.dispose();
    }
    _bumpController?.dispose();
    super.dispose();
  }

  void _syncExiting(List<ArrowEntity> previous, List<ArrowEntity> current) {
    final currentIds = current.map((a) => a.id).toSet();
    for (final arrow in previous) {
      if (currentIds.contains(arrow.id)) continue;
      final controller = AnimationController(vsync: this, duration: _exitDuration);
      late final _ExitAnim anim;
      anim = _ExitAnim(arrow: arrow, controller: controller);
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      controller.forward().whenComplete(() {
        if (!mounted) return;
        setState(() => _exiting.remove(anim));
        controller.dispose();
      });
      _exiting.add(anim);
    }
  }

  void _startBump(String id) {
    _bumpController?.dispose();
    _bumpingId = id;
    _bumpController = AnimationController(vsync: this, duration: _bumpDuration)
      ..addListener(() {
        if (mounted) setState(() {});
      })
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _bumpingId = null;
        });
      });
  }

  void _onPanStart(DragStartDetails details) {
    _dragAccum = Offset.zero;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _dragAccum += details.delta;
    setState(() {
      _yaw += details.delta.dx * _dragToRadians;
      _pitch = (_pitch - details.delta.dy * _dragToRadians).clamp(
        -math.pi / 2 + 0.05,
        math.pi / 2 - 0.05,
      );
    });
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    if (_dragAccum.distance > _tapDisplacementThreshold) return;
    _handleTap(_lastTapPosition, size);
  }

  void _handleTap(Offset local, Size size) {
    final onTap = widget.onArrowTap;
    if (onTap == null) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxDim = [widget.width, widget.height, widget.depth]
        .reduce(math.max)
        .toDouble();
    final cellSize = size.shortestSide * 0.62 / maxDim;
    final cameraDistance = maxDim * 1.7;
    final rotation = Cube3DProjection.rotationFor(_yaw, _pitch);

    String? bestId;
    var bestDepth = double.infinity;
    var bestDistance = double.infinity;

    for (final arrow in widget.arrows) {
      final node = arrow.occupiedNodes.single as Cube3DNodeId;
      final base = Cube3DProjection.cellToModel(
        node.x,
        widget.height - 1 - node.y,
        node.z,
        widget.width,
        widget.height,
        widget.depth,
      );
      final projected = Cube3DProjection.project(
        base,
        rotation,
        cellSize: cellSize,
        cameraDistance: cameraDistance,
        center: center,
      );
      final distance = (projected.screen - local).distance;
      final hitRadius = cellSize * 0.5;
      if (distance <= hitRadius && projected.depth < bestDepth) {
        bestDepth = projected.depth;
        bestDistance = distance;
        bestId = arrow.id;
      }
    }

    if (bestId != null && bestDistance <= cellSize * 0.5) {
      onTap(bestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerDown: (event) => _lastTapPosition = event.localPosition,
          child: GestureDetector(
            key: const Key('cubeBoardGesture'),
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: (details) => _onPanEnd(details, size),
            child: CustomPaint(
              size: size,
              painter: CubeBoardPainter(
                arrows: widget.arrows,
                width: widget.width,
                height: widget.height,
                depth: widget.depth,
                rotation: Cube3DProjection.rotationFor(_yaw, _pitch),
                colorOf: widget.colorOf,
                exiting: [
                  for (final anim in _exiting)
                    ExitingCubelet(
                      arrow: anim.arrow,
                      progress: anim.controller.value,
                    ),
                ],
                bumpingId: _bumpingId,
                bumpProgress: _bumpController?.value ?? 0.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExitAnim {
  _ExitAnim({required this.arrow, required this.controller});
  final ArrowEntity arrow;
  final AnimationController controller;
}
