import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../game/domain/entities/arrow_entity.dart';
import '../../../game/domain/entities/hex_level.dart';
import '../../../game/presentation/bloc/hex/hex_game_cubit.dart';
import '../../../game/presentation/screens/game_hex_screen.dart';
import '../../../game/presentation/widgets/arrow_color_assigner.dart';
import '../../../game/presentation/widgets/hex/hex_board_painter.dart';
import '../../../game/presentation/widgets/hex/hex_geometry.dart';
import '../bloc/hex_level_editor_cubit.dart';
import '../bloc/hex_level_editor_state.dart';

/// The hexagonal-board level editor — the hex sibling of [LevelEditorScreen]:
/// drag from an empty hex cell along one of the 6 axial directions to sketch
/// a straight arrow, tap a placed arrow to select it (tap again to rotate),
/// use +/- to resize, the trash button to remove it. See
/// [HexLevelEditorState] for why arrows are straight-only here too.
class HexLevelEditorScreen extends StatelessWidget {
  const HexLevelEditorScreen({super.key, this.existing});

  /// The level being edited, if resuming a saved draft. Null for a
  /// brand-new level.
  final HexLevel? existing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HexLevelEditorCubit>(
      create: (_) {
        final cubit = sl<HexLevelEditorCubit>();
        final level = existing;
        if (level != null) {
          cubit.loadExisting(level);
        }
        return cubit;
      },
      child: const _HexLevelEditorView(),
    );
  }
}

class _HexLevelEditorView extends StatelessWidget {
  const _HexLevelEditorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          AppScreenHeader(
            title: 'Editor hexagonal',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: BlocConsumer<HexLevelEditorCubit, HexLevelEditorState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage!)),
                  );
                } else if (state.infoMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.infoMessage!)),
                  );
                }
              },
              builder: (context, state) {
                final cubit = context.read<HexLevelEditorCubit>();
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MetadataForm(state: state, cubit: cubit),
                          const SizedBox(height: AppSpacing.sm),
                          _HexBoardEditor(state: state, cubit: cubit),
                          const SizedBox(height: AppSpacing.xs),
                          if (state.selectedArrowId != null)
                            _SelectedArrowToolbar(state: state, cubit: cubit)
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Arrastra desde un hexágono vacío para trazar una flecha.',
                                textAlign: TextAlign.center,
                                style: AppTypography.label(),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          _ActionButtons(state: state, cubit: cubit),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataForm extends StatelessWidget {
  const _MetadataForm({required this.state, required this.cubit});

  final HexLevelEditorState state;
  final HexLevelEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: state.name,
                    enabled: !state.isPublished,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      isDense: true,
                    ),
                    onChanged: cubit.setName,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.difficulty,
                    isDense: true,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: const InputDecoration(
                      labelText: 'Dificultad',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Easy', child: Text('Fácil')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medio')),
                      DropdownMenuItem(value: 'Hard', child: Text('Difícil')),
                    ],
                    onChanged: state.isPublished
                        ? null
                        : (v) {
                            if (v != null) cubit.setDifficulty(v);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Stepper(
                  label: 'Radio',
                  value: state.radius,
                  min: 1,
                  max: 6,
                  onChanged: state.isPublished ? null : cubit.setRadius,
                ),
                _Stepper(
                  label: 'Tiempo (s)',
                  value: state.timeLimitSeconds ?? 60,
                  min: 10,
                  max: 300,
                  step: 10,
                  onChanged: state.isPublished
                      ? null
                      : (v) => cubit.setTimeLimitSeconds(v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _miniButton(
              Icons.remove,
              onChanged == null || value <= min
                  ? null
                  : () => onChanged!(value - step),
            ),
            SizedBox(
              width: 26,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            _miniButton(
              Icons.add,
              onChanged == null || value >= max
                  ? null
                  : () => onChanged!(value + step),
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, size: 15),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
    );
  }
}

/// The hex board: sized to use nearly the full available width (the whole
/// editor already scrolls vertically, so the board isn't squeezed to fit a
/// fixed height the way a non-scrolling layout would need), centered
/// regardless of the surrounding column's width. Arrows are drawn with
/// [HexArrowsLayerPainter] — the same painter the real hex game board
/// uses — so the editor's arrows look identical to gameplay.
class _HexBoardEditor extends StatefulWidget {
  const _HexBoardEditor({required this.state, required this.cubit});

  final HexLevelEditorState state;
  final HexLevelEditorCubit cubit;

  @override
  State<_HexBoardEditor> createState() => _HexBoardEditorState();
}

class _HexBoardEditorState extends State<_HexBoardEditor> {
  final _colorAssigner = ArrowColorAssigner();

  static const double _maxBoardSide = 480;
  static const double _minHexSize = 24;
  static const double _maxHexSize = 56;
  static const double _sqrt3 = 1.7320508075688772;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;
    final radius = state.radius;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxWidth < _maxBoardSide ? constraints.maxWidth : _maxBoardSide;
        final widthFactor = _sqrt3 * (2 * radius + 1);
        // Pointy-top hex: row-center spacing is 1.5*size and row centers
        // span 2*radius rows, so the row-center range alone is
        // 3*radius*size; add one hex's half-height (= size) on top and
        // bottom for the board's true vertical extent. (Using half of this
        // — the previous bug — sized the canvas for only the middle band of
        // rows, clipping the top and bottom ones.)
        final heightFactor = 3 * radius + 2;
        final hexSize = (available / widthFactor)
            .clamp(_minHexSize, _maxHexSize)
            .toDouble();
        final boardWidth = hexSize * widthFactor;
        final boardHeight = hexSize * heightFactor;
        final size = Size(boardWidth, boardHeight);
        final origin = Offset(boardWidth / 2, boardHeight / 2);

        ArrowEntity? selectedArrow;
        if (state.selectedArrowId != null) {
          for (final a in state.arrows) {
            if (a.id == state.selectedArrowId) {
              selectedArrow = a;
              break;
            }
          }
        }

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: state.isPublished
                    ? null
                    : (d) {
                        final (q, r) = pixelToAxial(d.localPosition - origin, hexSize);
                        cubit.beginDrag(q, r);
                      },
                onPanUpdate: state.isPublished
                    ? null
                    : (d) {
                        final (q, r) = pixelToAxial(d.localPosition - origin, hexSize);
                        cubit.updateDrag(q, r);
                      },
                onPanEnd: state.isPublished ? null : (_) => cubit.endDrag(),
                onPanCancel: state.isPublished ? null : cubit.endDrag,
                child: Stack(
                  children: [
                    Container(color: AppColors.textDark),
                    CustomPaint(
                      size: size,
                      painter: HexSurfacePainter(
                        radius: radius,
                        hexSize: hexSize,
                        origin: origin,
                      ),
                    ),
                    if (selectedArrow != null)
                      CustomPaint(
                        size: size,
                        painter: _HexSelectionHighlightPainter(
                          arrow: selectedArrow,
                          hexSize: hexSize,
                          origin: origin,
                        ),
                      ),
                    CustomPaint(
                      size: size,
                      painter: HexArrowsLayerPainter(
                        arrows: state.arrows,
                        colorOf: _colorAssigner.colorOf,
                        hexSize: hexSize,
                        origin: origin,
                      ),
                    ),
                    if (state.dragPreview != null)
                      CustomPaint(
                        size: size,
                        painter: HexArrowsLayerPainter(
                          arrows: [state.dragPreview!],
                          colorOf: (_) => Colors.white,
                          hexSize: hexSize,
                          origin: origin,
                          opacity: 0.6,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A soft highlight under every hex the selected arrow occupies.
class _HexSelectionHighlightPainter extends CustomPainter {
  const _HexSelectionHighlightPainter({
    required this.arrow,
    required this.hexSize,
    required this.origin,
  });

  final ArrowEntity arrow;
  final double hexSize;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.22);
    for (final node in arrow.occupiedNodes) {
      final (q, r) = qr(node);
      final center = origin + axialToPixel(q, r, hexSize);
      final corners = hexCorners(center, hexSize * 0.86);
      canvas.drawPath(Path()..addPolygon(corners, true), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HexSelectionHighlightPainter old) =>
      old.arrow != arrow || old.hexSize != hexSize || old.origin != origin;
}

class _SelectedArrowToolbar extends StatelessWidget {
  const _SelectedArrowToolbar({required this.state, required this.cubit});

  final HexLevelEditorState state;
  final HexLevelEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Flecha seleccionada — toca de nuevo para rotar',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: 'Acortar',
          onPressed: () => cubit.resizeSelected(-1),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Alargar',
          onPressed: () => cubit.resizeSelected(1),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          tooltip: 'Eliminar',
          onPressed: cubit.removeSelected,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.state, required this.cubit});

  final HexLevelEditorState state;
  final HexLevelEditorCubit cubit;

  Future<void> _testPlay(BuildContext context) async {
    final saved = await cubit.save();
    if (!saved || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<HexGameCubit>(
          create: (_) => sl<HexGameCubit>(),
          child: GameHexScreen(
            externalLevel: HexLevel(
              id: 'draft',
              name: state.name,
              difficulty: state.difficulty,
              radius: state.radius,
              templateBoard: cubit.currentBoard,
              timeLimitSeconds: state.timeLimitSeconds,
            ),
            onEditorTestSolved: cubit.markSolved,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!state.isPublished) ...[
          OutlinedButton.icon(
            onPressed: state.arrows.isEmpty ? null : () => _testPlay(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Probar nivel'),
          ),
          const SizedBox(height: 8),
          Text(
            state.hasBeenSolved
                ? '✅ Resuelto — ya puedes publicar'
                : 'Debes resolver el nivel antes de publicarlo',
            style: TextStyle(
              color: state.hasBeenSolved ? AppColors.success : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.isSaving ? null : () => cubit.save(),
            child: Text(state.isSaving ? 'Guardando…' : 'Guardar borrador'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: state.canPublish && !state.isSaving
                ? () => cubit.publish()
                : null,
            child: const Text('Publicar'),
          ),
        ] else
          const Text(
            'Este nivel ya está publicado y no se puede editar.',
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
