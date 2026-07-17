import 'package:equatable/equatable.dart';

import '../../../game/domain/entities/creative_level.dart';

/// Shared state shape for [CommunityLevelsCubit] and [MyLevelsCubit] — both
/// are "load a list of [CreativeLevel]s" screens with no other behavior.
sealed class CreativeListState extends Equatable {
  const CreativeListState();

  @override
  List<Object?> get props => [];
}

class CreativeListLoading extends CreativeListState {
  const CreativeListLoading();
}

class CreativeListLoaded extends CreativeListState {
  const CreativeListLoaded(this.levels);

  final List<CreativeLevel> levels;

  @override
  List<Object?> get props => [levels];
}

class CreativeListError extends CreativeListState {
  const CreativeListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
