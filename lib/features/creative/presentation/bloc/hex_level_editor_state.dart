import 'package:equatable/equatable.dart';

import '../../../game/domain/entities/arrow_entity.dart';

/// State for [HexLevelEditorCubit] — the hex sibling of [LevelEditorState].
///
/// Like the grid editor, arrows are built by dragging along a single hex
/// direction (straight bodies only — bending is a scope cut here too, for
/// the same reason: it needs a materially more complex interaction model).
/// Placement is drag-based: pressing an empty hex cell and dragging along
/// one of the 6 axial directions sketches [dragPreview] live; releasing
/// commits it as a new arrow (a drag that never moves collapses to a
/// 1-cell arrow, preserving a tap-to-place shortcut).
class HexLevelEditorState extends Equatable {
  const HexLevelEditorState({
    this.id,
    this.name = '',
    this.difficulty = 'Easy',
    this.radius = 2,
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
  final int radius;
  final List<ArrowEntity> arrows;
  final int? timeLimitSeconds;
  final String? selectedArrowId;

  /// The arrow currently being sketched by an in-progress drag gesture, not
  /// yet committed to [arrows]. Null when no drag is in progress.
  final ArrowEntity? dragPreview;

  /// Set once a test-play of the current saved draft ends in victory —
  /// required before [isPublished] can become true (publish-by-demonstration,
  /// mirrors the grid editor's ADR).
  final bool hasBeenSolved;
  final bool isPublished;
  final bool isSaving;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  bool get canPublish => id != null && hasBeenSolved && !isPublished;

  HexLevelEditorState copyWith({
    String? id,
    String? name,
    String? difficulty,
    int? radius,
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
    return HexLevelEditorState(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      radius: radius ?? this.radius,
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
        radius,
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
