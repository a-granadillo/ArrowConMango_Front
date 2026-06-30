import '../../domain/entities/app_progress.dart';
import '../models/app_progress_model.dart';

/// Mapper for converting between [AppProgress] and [AppProgressModel].
///
/// Handles the conversion of domain entities to data models for serialization
/// and vice versa.
class AppProgressMapper {
  /// Converts an [AppProgress] to an [AppProgressModel].
  static AppProgressModel toModel(AppProgress entity) {
    return AppProgressModel(
      unlockedLevels: entity.unlockedLevels,
      currentToken: entity.currentToken,
    );
  }

  /// Converts an [AppProgressModel] to an [AppProgress].
  static AppProgress toEntity(AppProgressModel model) {
    return AppProgress(
      unlockedLevels: model.unlockedLevels,
      currentToken: model.currentToken,
    );
  }
}
