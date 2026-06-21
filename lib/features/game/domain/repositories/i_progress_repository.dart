import '../entities/app_progress.dart';
import 'result.dart';

/// Contract for persisting and reading the player's progress.
///
/// Implementations may use local storage (Hive, SharedPreferences)
/// or a remote backend — the domain does not care (DIP).
abstract class IProgressRepository {
  /// Reads the player's current progress (unlocked levels, token).
  ///
  /// Returns [Error] if the data source is unavailable.
  /// Returns [Success] with a default [AppProgress] if none has been saved yet.
  Future<Result<AppProgress>> loadProgress();

  /// Persists the player's progress.
  ///
  /// Returns [Error] if the write fails.
  Future<Result<void>> saveProgress(AppProgress progress);
}
