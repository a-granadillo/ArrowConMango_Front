import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';

/// Manual fake for [IProgressRepository] shared across progress use-case tests.
///
/// Allows tests to configure the result returned by [loadProgress] and/or
/// [saveProgress], simulate unhandled exceptions, and inspect the progress
/// entity passed to [saveProgress].
class FakeProgressRepository implements IProgressRepository {
  Result<AppProgress>? loadResult;
  Result<void>? saveResult;
  Object? loadExceptionToThrow;
  Object? saveExceptionToThrow;
  AppProgress? savedProgress;

  @override
  Future<Result<AppProgress>> loadProgress() async {
    if (loadExceptionToThrow != null) {
      throw loadExceptionToThrow!;
    }

    return loadResult!;
  }

  @override
  Future<Result<void>> saveProgress(AppProgress progress) async {
    savedProgress = progress;

    if (saveExceptionToThrow != null) {
      throw saveExceptionToThrow!;
    }

    return saveResult!;
  }
}
