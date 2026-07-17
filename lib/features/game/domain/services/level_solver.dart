import '../entities/board_state.dart';
import 'collision_validator.dart';

/// Result of a solvability check: whether the board can be fully cleared,
/// and — when it can't — which arrows are permanently stuck.
class SolveResult {
  const SolveResult({required this.stuckArrowIds});

  final List<String> stuckArrowIds;

  bool get isSolvable => stuckArrowIds.isEmpty;
}

/// Decides whether a board has a solution: a sequence of moves that clears
/// every arrow.
///
/// Domain service — no PRNG, no randomness, deterministic. Used by:
///   - the level generator's own board acceptance check (Campaign/Survival),
///   - the level editor, to require an author demonstrate their level is
///     solvable before publishing (see the community-levels ADR),
///   - the solvability regression test suite.
///
/// The exit rule [CollisionValidator] enforces is monotone — removing an
/// arrow can only ever unblock others, never block one that was previously
/// clear — so a greedy drain (repeatedly remove any arrow whose exit path
/// is clear, until none can move) is an exact decision procedure: it clears
/// the board if and only if a solving order exists.
abstract final class LevelSolver {
  static SolveResult solve(BoardState board, CollisionValidator validator) {
    var current = board;
    var madeProgress = true;
    while (madeProgress && !current.isEmpty) {
      madeProgress = false;
      for (final arrow in current.arrows) {
        if (validator.checkExit(arrow, current).canExit) {
          current = current.withoutArrow(arrow);
          madeProgress = true;
          break;
        }
      }
    }
    return SolveResult(stuckArrowIds: current.arrows.map((a) => a.id).toList());
  }

  static bool isSolvable(BoardState board, CollisionValidator validator) =>
      solve(board, validator).isSolvable;
}
