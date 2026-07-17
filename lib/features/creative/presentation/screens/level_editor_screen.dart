import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/arrow_entity.dart';
import '../../../game/domain/entities/cardinal_direction.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../../../game/presentation/bloc/game_bloc.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../bloc/level_editor_cubit.dart';
import '../bloc/level_editor_state.dart';

/// The level editor: tap an empty cell to place a straight arrow, tap it
/// again to rotate, use +/- to resize, long-press (or the trash button) to
/// remove it. See [LevelEditorState] for why arrows are straight-only.
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MetadataForm(state: state, cubit: cubit),
                const SizedBox(height: 16),
                _BoardEditor(state: state, cubit: cubit),
                const SizedBox(height: 16),
                if (state.selectedArrowId != null)
                  _SelectedArrowToolbar(state: state, cubit: cubit),
                const SizedBox(height: 16),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: state.name,
              enabled: !state.isPublished,
              decoration: const InputDecoration(labelText: 'Nombre del nivel'),
              onChanged: cubit.setName,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: state.difficulty,
                    decoration: const InputDecoration(labelText: 'Dificultad'),
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
                const SizedBox(width: 12),
                Expanded(
                  child: _Stepper(
                    label: 'Filas',
                    value: state.rows,
                    min: 4,
                    max: 12,
                    onChanged: state.isPublished
                        ? null
                        : (v) => cubit.setBoardSize(rows: v, cols: state.cols),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Stepper(
                    label: 'Columnas',
                    value: state.cols,
                    min: 4,
                    max: 12,
                    onChanged: state.isPublished
                        ? null
                        : (v) => cubit.setBoardSize(rows: state.rows, cols: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Stepper(
              label: 'Límite de tiempo (s)',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onChanged == null || value <= min
                  ? null
                  : () => onChanged!(value - step),
            ),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onChanged == null || value >= max
                  ? null
                  : () => onChanged!(value + step),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoardEditor extends StatelessWidget {
  const _BoardEditor({required this.state, required this.cubit});

  final LevelEditorState state;
  final LevelEditorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: state.cols / state.rows,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textDark,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(6),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: state.cols,
          ),
          itemCount: state.rows * state.cols,
          itemBuilder: (context, index) {
            final row = index ~/ state.cols;
            final col = index % state.cols;
            final key = '${row}_$col';
            ArrowEntity? occupant;
            for (final a in state.arrows) {
              if (a.occupiedNodes.any((n) => n.key == key)) {
                occupant = a;
                break;
              }
            }
            final selected = occupant?.id == state.selectedArrowId;
            return GestureDetector(
              onTap: state.isPublished ? null : () => cubit.tapCell(row, col),
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: occupant == null
                      ? Colors.white.withValues(alpha: 0.08)
                      : (selected ? AppColors.mango : AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                  border: selected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: occupant == null
                    ? null
                    : Icon(
                        _iconFor(occupant.direction as CardinalDirection),
                        color: Colors.white,
                        size: 16,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _iconFor(CardinalDirection direction) => switch (direction) {
        CardinalDirection.up => Icons.arrow_upward,
        CardinalDirection.down => Icons.arrow_downward,
        CardinalDirection.left => Icons.arrow_back,
        CardinalDirection.right => Icons.arrow_forward,
      };
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
        Text(
          'Flecha seleccionada — toca de nuevo para rotar',
          style: Theme.of(context).textTheme.bodySmall,
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
