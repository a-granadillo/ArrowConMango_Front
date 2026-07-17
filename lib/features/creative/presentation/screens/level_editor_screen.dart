import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/arrow_entity.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../../../game/presentation/bloc/game_bloc.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../../game/presentation/widgets/arrow_color_assigner.dart';
import '../../../game/presentation/widgets/painting/arrow_geometry.dart';
import '../../../game/presentation/widgets/painting/arrows_layer_painter.dart';
import '../../../game/presentation/widgets/painting/board_surface_painter.dart';
import '../bloc/level_editor_cubit.dart';
import '../bloc/level_editor_state.dart';

/// The level editor: drag from an empty cell along a row or column to sketch
/// a straight arrow, tap a placed arrow to select it (tap again to rotate),
/// use +/- to resize, long-press (or the trash button) to remove it. See
/// [LevelEditorState] for why arrows are straight-only.
class LevelEditorScreen extends StatelessWidget {
  const LevelEditorScreen({super.key, this.existing});

  /// The level being edited, if resuming a saved draft. Null for a
  /// brand-new level.
  final CreativeLevel? existing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LevelEditorCubit>(
      create: (_) {
        final cubit = sl<LevelEditorCubit>();
        final level = existing;
        if (level != null) {
          cubit.loadExisting(level);
        }
        return cubit;
      },
      child: const _LevelEditorView(),
    );
  }
}

class _LevelEditorView extends StatelessWidget {
  const _LevelEditorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Editor de niveles'),
      ),
      body: BlocConsumer<LevelEditorCubit, LevelEditorState>(
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
          final cubit = context.read<LevelEditorCubit>();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MetadataForm(state: state, cubit: cubit),
                const SizedBox(height: 12),
                _BoardEditor(state: state, cubit: cubit),
                const SizedBox(height: 8),
                if (state.selectedArrowId != null)
                  _SelectedArrowToolbar(state: state, cubit: cubit)
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Arrastra desde una celda vacía para trazar una flecha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
                const SizedBox(height: 12),
                _ActionButtons(state: state, cubit: cubit),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetadataForm extends StatelessWidget {
  const _MetadataForm({required this.state, required this.cubit});

  final LevelEditorState state;
  final LevelEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                  label: 'Filas',
                  value: state.rows,
                  min: 4,
                  max: 12,
                  onChanged: state.isPublished
                      ? null
                      : (v) => cubit.setBoardSize(rows: v, cols: state.cols),
                ),
                _Stepper(
                  label: 'Columnas',
                  value: state.cols,
                  min: 4,
                  max: 12,
                  onChanged: state.isPublished
                      ? null
                      : (v) => cubit.setBoardSize(rows: state.rows, cols: v),
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

/// The board: cell size is capped so the whole grid fits on screen without
/// scrolling, and centered regardless of the surrounding column's width.
/// Arrows are drawn with [ArrowsLayerPainter] — the same painter the real
/// 2D game board uses — so the editor's arrows look identical to gameplay.
class _BoardEditor extends StatefulWidget {
  const _BoardEditor({required this.state, required this.cubit});

  final LevelEditorState state;
  final LevelEditorCubit cubit;

  @override
  State<_BoardEditor> createState() => _BoardEditorState();
}

class _BoardEditorState extends State<_BoardEditor> {
  final _colorAssigner = ArrowColorAssigner();

  static const double _maxBoardSide = 300;
  static const double _minCell = 20;
  static const double _maxCell = 42;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = widget.cubit;
    final longestSide = state.rows > state.cols ? state.rows : state.cols;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth < _maxBoardSide
            ? constraints.maxWidth
            : _maxBoardSide;
        final cell = (available / longestSide).clamp(_minCell, _maxCell);
        final boardWidth = cell * state.cols;
        final boardHeight = cell * state.rows;
        final size = Size(boardWidth, boardHeight);

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
                        final (row, col) = _cellAt(d.localPosition, cell, state);
                        cubit.beginDrag(row, col);
                      },
                onPanUpdate: state.isPublished
                    ? null
                    : (d) {
                        final (row, col) = _cellAt(d.localPosition, cell, state);
                        cubit.updateDrag(row, col);
                      },
                onPanEnd: state.isPublished ? null : (_) => cubit.endDrag(),
                onPanCancel: state.isPublished ? null : cubit.endDrag,
                child: Stack(
                  children: [
                    Container(color: AppColors.textDark),
                    CustomPaint(size: size, painter: BoardSurfacePainter(cell)),
                    CustomPaint(
                      size: size,
                      painter: _GridLinesPainter(
                        cell: cell,
                        rows: state.rows,
                        cols: state.cols,
                      ),
                    ),
                    if (selectedArrow != null)
                      CustomPaint(
                        size: size,
                        painter: _SelectionHighlightPainter(
                          arrow: selectedArrow,
                          cell: cell,
                        ),
                      ),
                    CustomPaint(
                      size: size,
                      painter: ArrowsLayerPainter(
                        arrows: state.arrows,
                        colorOf: _colorAssigner.colorOf,
                        cell: cell,
                      ),
                    ),
                    if (state.dragPreview != null)
                      CustomPaint(
                        size: size,
                        painter: ArrowsLayerPainter(
                          arrows: [state.dragPreview!],
                          colorOf: (_) => Colors.white,
                          cell: cell,
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

  (int, int) _cellAt(Offset local, double cell, LevelEditorState state) {
    final col = (local.dx / cell).floor().clamp(0, state.cols - 1);
    final row = (local.dy / cell).floor().clamp(0, state.rows - 1);
    return (row, col);
  }
}

/// Faint 1px lines at every cell boundary — the real game board doesn't need
/// these (players don't place anything), but the editor benefits from a
/// visible grid to line up drags precisely.
class _GridLinesPainter extends CustomPainter {
  const _GridLinesPainter({
    required this.cell,
    required this.rows,
    required this.cols,
  });

  final double cell;
  final int rows;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (var c = 0; c <= cols; c++) {
      final x = c * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var r = 0; r <= rows; r++) {
      final y = r * cell;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter old) =>
      old.cell != cell || old.rows != rows || old.cols != cols;
}

/// A soft highlight under every cell the selected arrow occupies.
class _SelectionHighlightPainter extends CustomPainter {
  const _SelectionHighlightPainter({required this.arrow, required this.cell});

  final ArrowEntity arrow;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.22);
    for (final node in arrow.occupiedNodes) {
      final (r, c) = rc(node);
      final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell)
          .deflate(cell * 0.06);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.18)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SelectionHighlightPainter old) =>
      old.arrow != arrow || old.cell != cell;
}

class _SelectedArrowToolbar extends StatelessWidget {
  const _SelectedArrowToolbar({required this.state, required this.cubit});

  final LevelEditorState state;
  final LevelEditorCubit cubit;

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

  final LevelEditorState state;
  final LevelEditorCubit cubit;

  Future<void> _testPlay(BuildContext context) async {
    final saved = await cubit.save();
    if (!saved || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<GameBloc>(
          create: (_) => sl<GameBloc>(),
          child: GameScreen(
            externalLevel: CreativeLevel(
              id: 'draft',
              name: state.name,
              difficulty: state.difficulty,
              rows: state.rows,
              cols: state.cols,
              templateBoard: cubit.currentBoard,
              authorId: null,
              isPublished: false,
            ).toPlayableLevel(syntheticId: 999999),
            externalTimeLimitSeconds: state.timeLimitSeconds,
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
            onPressed: state.arrows.isEmpty
                ? null
                : () => _testPlay(context),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Probar nivel'),
          ),
          const SizedBox(height: 8),
          Text(
            state.hasBeenSolved
                ? '✅ Resuelto — ya puedes publicar'
                : 'Debes resolver el nivel antes de publicarlo',
            style: TextStyle(
              color: state.hasBeenSolved
                  ? AppColors.success
                  : AppColors.textMuted,
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
