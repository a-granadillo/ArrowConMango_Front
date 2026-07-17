import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/data/topologies/grid_2d_topology.dart';
import '../../../game/domain/entities/arrow_entity.dart';
import '../../../game/domain/entities/board_state.dart';
import '../../../game/domain/entities/cardinal_direction.dart';
import '../../../game/domain/entities/creative_level.dart';
import '../../../game/domain/entities/node_id.dart';
import '../../../game/domain/errors/overlapping_arrows_failure.dart';
import '../../../game/domain/repositories/i_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';
import 'level_editor_state.dart';

/// Drives the level editor: placing/rotating/resizing straight arrows,
/// board size and time limit, saving a draft, and publishing it once it's
/// been demonstrated solvable (see [LevelEditorState.hasBeenSolved]).
@injectable
class LevelEditorCubit extends Cubit<LevelEditorState> {
  LevelEditorCubit(this._repository) : super(const LevelEditorState());

  final ICreativeLevelRepository _repository;
  int _arrowSeq = 0;

  /// Loads an existing draft/published level for editing.
  Future<void> loadExisting(CreativeLevel level) async {
    emit(
      state.copyWith(
        id: level.id,
        name: level.name,
        difficulty: level.difficulty,
        rows: level.rows,
        cols: level.cols,
        arrows: level.templateBoard.arrows,
        timeLimitSeconds: level.timeLimitSeconds,
        clearTimeLimit: level.timeLimitSeconds == null,
        isPublished: level.isPublished,
        // A previously-saved level is, definitionally, playable — but we
        // don't know it was solved *in this editing session*, and publish
        // is only reachable pre-publish anyway (already-published levels
        // are read-only in the UI), so this only matters for a draft the
        // author is resuming: require a fresh demonstration.
        hasBeenSolved: false,
      ),
    );
  }

  void setName(String name) => emit(state.copyWith(name: name));

  void setDifficulty(String difficulty) =>
      emit(state.copyWith(difficulty: difficulty));

  void setTimeLimitSeconds(int? seconds) {
    if (seconds == null) {
      emit(state.copyWith(clearTimeLimit: true));
    } else {
      emit(state.copyWith(timeLimitSeconds: seconds));
    }
  }

  void setBoardSize({required int rows, required int cols}) {
    // Shrinking the board could strand out-of-bounds arrows; drop any that
    // no longer fit rather than leaving an invalid draft.
    final kept = state.arrows.where((a) {
      return a.occupiedNodes.every((n) {
        final node = n as Grid2DNodeId;
        return node.row < rows && node.col < cols;
      });
    }).toList();
    emit(
      state.copyWith(
        rows: rows,
        cols: cols,
        arrows: kept,
        clearSelection: true,
        hasBeenSolved: false,
      ),
    );
  }

  /// Tapping a cell: selects the arrow occupying it, or — if empty — places
  /// a brand-new 1-cell arrow there.
  void tapCell(int row, int col) {
    final key = Grid2DNodeId(row: row, col: col).key;
    final existing = state.arrows.where(
      (a) => a.occupiedNodes.any((n) => n.key == key),
    );
    if (existing.isNotEmpty) {
      final tapped = existing.first;
      if (state.selectedArrowId == tapped.id) {
        _rotateSelected();
      } else {
        emit(state.copyWith(selectedArrowId: tapped.id, clearInfo: true));
      }
      return;
    }
    _placeNewArrow(row, col);
  }

  void _placeNewArrow(int row, int col) {
    final id = 'a${_arrowSeq++}';
    final arrow = ArrowEntity(
      id: id,
      direction: CardinalDirection.right,
      occupiedNodes: [Grid2DNodeId(row: row, col: col)],
    );
    if (!_fitsWithoutOverlap([...state.arrows, arrow])) return;
    emit(
      state.copyWith(
        arrows: [...state.arrows, arrow],
        selectedArrowId: id,
        hasBeenSolved: false,
        clearInfo: true,
      ),
    );
  }

  void removeSelected() {
    final selectedId = state.selectedArrowId;
    if (selectedId == null) return;
    emit(
      state.copyWith(
        arrows: state.arrows.where((a) => a.id != selectedId).toList(),
        clearSelection: true,
        hasBeenSolved: false,
      ),
    );
  }

  void _rotateSelected() {
    final selectedId = state.selectedArrowId;
    if (selectedId == null) return;
    final updated = state.arrows.map((a) {
      if (a.id != selectedId) return a;
      final next = _nextDirection(a.direction as CardinalDirection);
      final tail = a.occupiedNodes.first as Grid2DNodeId;
      return ArrowEntity(
        id: a.id,
        direction: next,
        occupiedNodes: _straightRun(tail.row, tail.col, next, a.length),
      );
    }).toList();
    if (!_fitsWithoutOverlap(updated)) return;
    emit(state.copyWith(arrows: updated, hasBeenSolved: false));
  }

  void resizeSelected(int delta) {
    final selectedId = state.selectedArrowId;
    if (selectedId == null) return;
    final updated = <ArrowEntity>[];
    for (final a in state.arrows) {
      if (a.id != selectedId) {
        updated.add(a);
        continue;
      }
      final newLength = a.length + delta;
      if (newLength < 1) return;
      final tail = a.occupiedNodes.first as Grid2DNodeId;
      updated.add(
        ArrowEntity(
          id: a.id,
          direction: a.direction,
          occupiedNodes: _straightRun(
            tail.row,
            tail.col,
            a.direction as CardinalDirection,
            newLength,
          ),
        ),
      );
    }
    if (!_fitsWithoutOverlap(updated)) return;
    emit(state.copyWith(arrows: updated, hasBeenSolved: false));
  }

  List<NodeId> _straightRun(
    int startRow,
    int startCol,
    CardinalDirection direction,
    int length,
  ) {
    final (dr, dc) = switch (direction) {
      CardinalDirection.up => (-1, 0),
      CardinalDirection.down => (1, 0),
      CardinalDirection.left => (0, -1),
      CardinalDirection.right => (0, 1),
    };
    return [
      for (var i = 0; i < length; i++)
        Grid2DNodeId(row: startRow + dr * i, col: startCol + dc * i),
    ];
  }

  CardinalDirection _nextDirection(CardinalDirection direction) => switch (
      direction) {
    CardinalDirection.up => CardinalDirection.right,
    CardinalDirection.right => CardinalDirection.down,
    CardinalDirection.down => CardinalDirection.left,
    CardinalDirection.left => CardinalDirection.up,
  };

  bool _fitsWithoutOverlap(List<ArrowEntity> arrows) {
    for (final a in arrows) {
      for (final n in a.occupiedNodes) {
        final node = n as Grid2DNodeId;
        if (node.row < 0 ||
            node.row >= state.rows ||
            node.col < 0 ||
            node.col >= state.cols) {
          return false;
        }
      }
    }
    try {
      BoardState(arrows: arrows);
      return true;
    } on OverlappingArrowsFailure {
      return false;
    }
  }

  /// The playable board for the current draft — used both to launch a
  /// test-play session and, via [LevelSolver], to gate publishing.
  BoardState get currentBoard => BoardState(arrows: state.arrows);

  /// Called by the game screen after a test-play of this draft. Only a
  /// genuine victory counts — see the community-levels solvability ADR.
  void markSolved() => emit(state.copyWith(hasBeenSolved: true));

  Future<bool> save() async {
    if (state.arrows.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Agrega al menos una flecha antes de guardar.',
        ),
      );
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true, clearInfo: true));

    final draft = CreativeLevel(
      id: state.id ?? '',
      name: state.name.isEmpty ? 'Nivel sin nombre' : state.name,
      difficulty: state.difficulty,
      rows: state.rows,
      cols: state.cols,
      templateBoard: currentBoard,
      authorId: null,
      isPublished: state.isPublished,
      timeLimitSeconds: state.timeLimitSeconds,
      maxMistakes: 3,
    );

    final result = state.id == null
        ? await _repository.createLevel(draft)
        : await _repository.updateLevel(draft);

    switch (result) {
      case Success(:final value):
        emit(
          state.copyWith(
            id: value.id,
            isSaving: false,
            infoMessage: 'Nivel guardado.',
          ),
        );
        return true;
      case Error(:final failure):
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
    }
  }

  Future<bool> publish() async {
    final id = state.id;
    if (id == null || !state.hasBeenSolved) return false;
    emit(state.copyWith(isSaving: true, clearError: true, clearInfo: true));
    final result = await _repository.publishLevel(id);
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            isSaving: false,
            isPublished: true,
            infoMessage: '¡Nivel publicado!',
          ),
        );
        return true;
      case Error(:final failure):
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        return false;
    }
  }
}
