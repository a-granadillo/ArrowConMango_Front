import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../game/data/topologies/hex_graph.dart';
import '../../../game/domain/entities/arrow_entity.dart';
import '../../../game/domain/entities/board_state.dart';
import '../../../game/domain/entities/hex_direction.dart';
import '../../../game/domain/entities/hex_level.dart';
import '../../../game/domain/entities/node_id.dart';
import '../../../game/domain/errors/overlapping_arrows_failure.dart';
import '../../../game/domain/repositories/i_hex_creative_level_repository.dart';
import '../../../game/domain/repositories/result.dart';
import 'hex_level_editor_state.dart';

const double _sqrt3 = 1.7320508075688772;

/// Drives the hexagonal-board level editor — the hex sibling of
/// [LevelEditorCubit]: placing/rotating/resizing straight arrows, board
/// radius and time limit, saving a draft, and publishing it once it's been
/// demonstrated solvable (see [HexLevelEditorState.hasBeenSolved]).
@injectable
class HexLevelEditorCubit extends Cubit<HexLevelEditorState> {
  HexLevelEditorCubit(this._repository) : super(const HexLevelEditorState());

  final IHexCreativeLevelRepository _repository;
  int _arrowSeq = 0;

  /// Axial cell the current drag gesture started on, if any (q, r).
  (int, int)? _dragOrigin;

  /// Loads an existing draft/published level for editing.
  Future<void> loadExisting(HexLevel level) async {
    emit(
      state.copyWith(
        id: level.id,
        name: level.name,
        difficulty: level.difficulty,
        radius: level.radius,
        arrows: level.templateBoard.arrows,
        timeLimitSeconds: level.timeLimitSeconds,
        clearTimeLimit: level.timeLimitSeconds == null,
        isPublished: level.isPublished,
        // Mirrors the grid editor: a previously-saved level is playable by
        // definition, but publish requires a fresh demonstration this
        // session (already-published levels are read-only in the UI).
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

  void setRadius(int radius) {
    // Shrinking the board could strand out-of-bounds arrows; drop any that
    // no longer fit rather than leaving an invalid draft.
    final kept = state.arrows.where((a) {
      return a.occupiedNodes.every((n) => _inBounds(n as HexNodeId, radius));
    }).toList();
    emit(
      state.copyWith(
        radius: radius,
        arrows: kept,
        clearSelection: true,
        hasBeenSolved: false,
      ),
    );
  }

  /// Pressing down on a hex cell: if it's already occupied, select it
  /// (tapping a selected arrow again rotates it). If it's empty, start
  /// sketching a new arrow from there — [updateDrag] and [endDrag] shape
  /// and commit it as the finger moves.
  void beginDrag(int q, int r) {
    if (state.isPublished) return;
    final key = HexNodeId(q: q, r: r).key;
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
    _dragOrigin = (q, r);
    emit(
      state.copyWith(
        clearSelection: true,
        dragPreview: _previewArrow(q, r, q, r),
        clearInfo: true,
      ),
    );
  }

  /// Updates the in-progress [HexLevelEditorState.dragPreview] as the finger
  /// moves over axial cell ([q], [r]). No-op if no drag is in progress.
  void updateDrag(int q, int r) {
    final origin = _dragOrigin;
    if (origin == null) return;
    emit(
      state.copyWith(dragPreview: _previewArrow(origin.$1, origin.$2, q, r)),
    );
  }

  /// Commits the sketched [HexLevelEditorState.dragPreview] as a new arrow,
  /// or silently discards it if it would overlap another arrow. No-op if no
  /// drag is in progress.
  void endDrag() {
    final preview = state.dragPreview;
    _dragOrigin = null;
    if (preview == null) {
      emit(state.copyWith(clearDragPreview: true));
      return;
    }
    final arrow = ArrowEntity(
      id: 'a${_arrowSeq++}',
      direction: preview.direction,
      occupiedNodes: preview.occupiedNodes,
    );
    if (!_fitsWithoutOverlap([...state.arrows, arrow])) {
      emit(
        state.copyWith(
          clearDragPreview: true,
          errorMessage: 'Esa flecha se sale del tablero o se cruza con otra.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        arrows: [...state.arrows, arrow],
        selectedArrowId: arrow.id,
        clearDragPreview: true,
        hasBeenSolved: false,
      ),
    );
  }

  /// Builds the straight-line preview arrow from axial ([startQ], [startR])
  /// to wherever the finger currently is, clamped to the board bounds. A
  /// drag that hasn't moved yet collapses to a 1-cell arrow.
  ArrowEntity _previewArrow(int startQ, int startR, int currentQ, int currentR) {
    final dq = currentQ - startQ;
    final dr = currentR - startR;
    if (dq == 0 && dr == 0) {
      return ArrowEntity(
        id: '_preview',
        direction: HexDirection.se,
        occupiedNodes: [HexNodeId(q: startQ, r: startR)],
      );
    }

    final direction = _bestDirectionFor(dq, dr);
    final steps = (_pixelDistance(dq, dr) / _sqrt3).round();
    final length = (steps + 1).clamp(
      1,
      _maxStepsInBounds(startQ, startR, direction),
    );
    return ArrowEntity(
      id: '_preview',
      direction: direction,
      occupiedNodes: _straightRun(startQ, startR, direction, length),
    );
  }

  /// The hex direction whose axial vector is closest (by angle) to (dq, dr).
  HexDirection _bestDirectionFor(int dq, int dr) {
    final (px, py) = _pixel(dq, dr);
    var best = HexDirection.se;
    var bestDot = double.negativeInfinity;
    for (final dir in HexDirection.values) {
      final (vq, vr) = _axialVector(dir);
      final (vx, vy) = _pixel(vq, vr);
      final vlen = math.sqrt(vx * vx + vy * vy);
      final dot = (px * vx + py * vy) / vlen;
      if (dot > bestDot) {
        bestDot = dot;
        best = dir;
      }
    }
    return best;
  }

  static (double, double) _pixel(int q, int r) =>
      (_sqrt3 * q + _sqrt3 / 2 * r, 1.5 * r);

  static double _pixelDistance(int q, int r) {
    final (x, y) = _pixel(q, r);
    return math.sqrt(x * x + y * y);
  }

  static (int, int) _axialVector(HexDirection direction) => switch (direction) {
        HexDirection.n => (0, -1),
        HexDirection.ne => (1, -1),
        HexDirection.se => (1, 0),
        HexDirection.s => (0, 1),
        HexDirection.sw => (-1, 1),
        HexDirection.nw => (-1, 0),
      };

  /// How many cells fit between axial ([q], [r]) and the board edge along
  /// [direction], inclusive of the starting cell.
  int _maxStepsInBounds(int q, int r, HexDirection direction) {
    final (dq, dr) = _axialVector(direction);
    var curQ = q, curR = r, n = 0;
    while (_inBounds(HexNodeId(q: curQ, r: curR), state.radius)) {
      n++;
      curQ += dq;
      curR += dr;
    }
    return n;
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
      final next = _nextDirection(a.direction as HexDirection);
      final tail = a.occupiedNodes.first as HexNodeId;
      return ArrowEntity(
        id: a.id,
        direction: next,
        occupiedNodes: _straightRun(tail.q, tail.r, next, a.length),
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
      final tail = a.occupiedNodes.first as HexNodeId;
      updated.add(
        ArrowEntity(
          id: a.id,
          direction: a.direction,
          occupiedNodes: _straightRun(
            tail.q,
            tail.r,
            a.direction as HexDirection,
            newLength,
          ),
        ),
      );
    }
    if (!_fitsWithoutOverlap(updated)) return;
    emit(state.copyWith(arrows: updated, hasBeenSolved: false));
  }

  List<NodeId> _straightRun(
    int startQ,
    int startR,
    HexDirection direction,
    int length,
  ) {
    final (dq, dr) = _axialVector(direction);
    return [
      for (var i = 0; i < length; i++)
        HexNodeId(q: startQ + dq * i, r: startR + dr * i),
    ];
  }

  HexDirection _nextDirection(HexDirection direction) => switch (direction) {
        HexDirection.n => HexDirection.ne,
        HexDirection.ne => HexDirection.se,
        HexDirection.se => HexDirection.s,
        HexDirection.s => HexDirection.sw,
        HexDirection.sw => HexDirection.nw,
        HexDirection.nw => HexDirection.n,
      };

  static bool _inBounds(HexNodeId node, int radius) {
    final maxAbs = math.max(node.q.abs(), math.max(node.r.abs(), node.s.abs()));
    return maxAbs <= radius;
  }

  bool _fitsWithoutOverlap(List<ArrowEntity> arrows) {
    for (final a in arrows) {
      for (final n in a.occupiedNodes) {
        if (!_inBounds(n as HexNodeId, state.radius)) return false;
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
  /// test-play session and to gate publishing.
  BoardState get currentBoard => BoardState(arrows: state.arrows);

  /// Called by the game screen after a test-play of this draft. Only a
  /// genuine victory counts — see the grid editor's solvability ADR.
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

    final draft = HexLevel(
      id: state.id ?? '',
      name: state.name.isEmpty ? 'Nivel sin nombre' : state.name,
      difficulty: state.difficulty,
      radius: state.radius,
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
