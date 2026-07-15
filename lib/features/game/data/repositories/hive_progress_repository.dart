import 'package:arrowconmango_front/features/game/data/models/app_progress_model.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/app_progress_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/entities/app_progress.dart';
import 'package:arrowconmango_front/features/game/domain/errors/generic_failure.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/i_progress_repository.dart';
import 'package:arrowconmango_front/features/game/domain/repositories/result.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Hive-backed implementation of [IProgressRepository].
///
/// Persists [AppProgressModel] objects in a [Box] under a single key
/// and maps them to/from the domain [AppProgress] entity.
@lazySingleton
class HiveProgressRepository implements IProgressRepository {
  /// Hive key the single [AppProgressModel] record is stored under.
  static const String progressKey = 'app_progress';

  final Box<AppProgressModel> _progressBox;
  final AppProgressMapper _progressMapper;

  HiveProgressRepository(
    this._progressBox,
    this._progressMapper,
  );

  @override
  Future<Result<AppProgress>> loadProgress() async {
    try {
      final model = _progressBox.get(progressKey);
      if (model == null) {
        return const Success<AppProgress>(AppProgress());
      }

      return Success<AppProgress>(_progressMapper.toEntity(model));
    } catch (e) {
      return Error<AppProgress>(
        GenericFailure('Failed to load progress: $e'),
      );
    }
  }

  @override
  Future<Result<void>> saveProgress(AppProgress progress) async {
    try {
      final model = _progressMapper.toModel(progress);
      await _progressBox.put(progressKey, model);
      return const Success<void>(null);
    } catch (e) {
      return Error<void>(
        GenericFailure('Failed to save progress: $e'),
      );
    }
  }
}
