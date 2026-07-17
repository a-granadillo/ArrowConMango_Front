import 'package:equatable/equatable.dart';

import '../../../game/domain/entities/arrow_entity.dart';

/// State for [LevelEditorCubit].
///
/// The editor only builds straight (single-segment) arrows — no bends.
/// This is a deliberate scope cut: multi-segment editing (choosing where a
/// path bends) needs a materially more complex interaction model than
/// drag-to-place / tap-to-rotate / +/- to resize. Straight arrows are fully
/// valid levels (LevelDefinition.validate() has no bend requirement) and
/// exercise the same solver, publish, and ranking flow.
///
/// Placement is drag-based: pressing an empty cell and dragging along a row
/// or column sketches [dragPreview] live; releasing commits it as a new
/// arrow (a drag that never moves collapses to a 1-cell arrow, preserving
/// the old tap-to-place shortcut).
class LevelEditorState extends Equatable {
  const LevelEditorState({
    this.id,
    this.name = '',
    this.difficulty = 'Easy',
    this.rows = 6,
    this.cols = 6,
    this.arrows = const [],
    this.timeLimitSeconds,
    this.selectedArrowId,
    this.dragPreview,
    this.hasBeenSolved = false,
    this.isPublished = false,
    this.isSaving = false,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  /// Backend id once the draft has been saved at least once. Null for a
  /// brand-new, never-saved draft.
  final String? id;
  final String name;
  final String difficulty;
  final int rows;
  final int cols;
  final List<ArrowEntity> arrows;
  final int? timeLimitSeconds;
  final String? selectedArrowId;

  /// The arrow currently being sketched by an in-progress drag gesture, not
  /// yet committed to [arrows]. Null when no drag is in progress.
  final ArrowEntity? dragPreview;

  /// Set once a test-play of the current saved draft ends in victory —
  /// required before [isPublished] can become true (see the
  /// community-levels solvability ADR: publish-by-demonstration).
  final bool hasBeenSolved;
  final bool isPublished;
  final bool isSaving;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  bool get canPublish => id != null && hasBeenSolved && !isPublished;

  LevelEditorState copyWith({
    String? id,
    String? name,
    String? difficulty,
    int? rows,
    int? cols,
    List<ArrowEntity>? arrows,
    int? timeLimitSeconds,
    bool clearTimeLimit = false,
    String? selectedArrowId,
    bool clearSelection = false,
    ArrowEntity? dragPreview,
    bool clearDragPreview = false,
    bool? hasBeenSolved,
    bool? isPublished,
    bool? isSaving,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return LevelEditorState(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      arrows: arrows ?? this.arrows,
      timeLimitSeconds:
          clearTimeLimit ? null : (timeLimitSeconds ?? this.timeLimitSeconds),
      selectedArrowId:
          clearSelection ? null : (selectedArrowId ?? this.selectedArrowId),
      dragPreview:
          clearDragPreview ? null : (dragPreview ?? this.dragPreview),
      hasBeenSolved: hasBeenSolved ?? this.hasBeenSolved,
      isPublished: isPublished ?? this.isPublished,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        difficulty,
        rows,
        cols,
        arrows,
        timeLimitSeconds,
        selectedArrowId,
        dragPreview,
        hasBeenSolved,
        isPublished,
        isSaving,
        isLoading,
        errorMessage,
        infoMessage,
      ];
}
