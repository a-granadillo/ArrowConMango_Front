import 'package:equatable/equatable.dart';

/// Serializable representation of [LevelBest].
class LevelBestModel extends Equatable {
  final int moves;
  final int timeElapsedSeconds;

  const LevelBestModel({
    required this.moves,
    required this.timeElapsedSeconds,
  });

  factory LevelBestModel.fromJson(Map<String, dynamic> json) {
    return LevelBestModel(
      moves: json['moves'] as int,
      timeElapsedSeconds: json['timeElapsedSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'moves': moves,
        'timeElapsedSeconds': timeElapsedSeconds,
      };

  @override
  List<Object?> get props => [moves, timeElapsedSeconds];
}
