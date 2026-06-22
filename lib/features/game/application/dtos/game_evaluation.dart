import 'package:equatable/equatable.dart';

import '../../domain/entities/score.dart';

enum GameStatus { ongoing, victory }

class GameEvaluation extends Equatable {
  final GameStatus status;
  final Score score;
  final int moveCount;
  final int elapsedSeconds;
  final int arrowsRemaining;

  const GameEvaluation({
    required this.status,
    required this.score,
    required this.moveCount,
    required this.elapsedSeconds,
    required this.arrowsRemaining,
  });

  @override
  List<Object?> get props => [
        status,
        score,
        moveCount,
        elapsedSeconds,
        arrowsRemaining,
      ];
}