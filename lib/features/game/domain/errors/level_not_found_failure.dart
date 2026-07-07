import 'failure.dart';

/// Failure emitted when a requested level does not exist in the data source.
class LevelNotFoundFailure extends Failure {
  /// The identifier of the level that could not be found.
  final int levelId;

  const LevelNotFoundFailure({required this.levelId})
      : super('Level $levelId not found');

  @override
  List<Object?> get props => [message, levelId];
}
