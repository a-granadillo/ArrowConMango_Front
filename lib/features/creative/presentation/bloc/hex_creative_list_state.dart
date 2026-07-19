import 'package:equatable/equatable.dart';

import '../../../game/domain/entities/hex_level.dart';

/// Shared state shape for [HexCommunityLevelsCubit] and [HexMyLevelsCubit]
/// — the hex sibling of [CreativeListState] — both are "load a list of
/// [HexLevel]s" screens with no other behavior.
sealed class HexCreativeListState extends Equatable {
  const HexCreativeListState();

  @override
  List<Object?> get props => [];
}

class HexCreativeListLoading extends HexCreativeListState {
  const HexCreativeListLoading();
}

class HexCreativeListLoaded extends HexCreativeListState {
  const HexCreativeListLoaded(this.levels);

  final List<HexLevel> levels;

  @override
  List<Object?> get props => [levels];
}

class HexCreativeListError extends HexCreativeListState {
  const HexCreativeListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
