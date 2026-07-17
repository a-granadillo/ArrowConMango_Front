import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/app_progress_model.dart';
import '../models/level_best_model.dart';

/// Talks to the backend's `/progress` endpoint.
///
/// The wire format (`completed`/`best`/`currentLevel`, level IDs as
/// strings) differs from [AppProgressModel.toJson]/`fromJson`
/// (`completedLevels`/`best` with int keys), and `best`'s time unit differs
/// too (wire: milliseconds; [LevelBestModel]: seconds), so this class maps
/// fields explicitly instead of reusing those methods.
///
/// Campaign level IDs are plain integers on the wire (`'1'`..`'15'`); a
/// non-numeric ID (e.g. a future community-level UUID) is skipped rather
/// than crashing the whole fetch.
@lazySingleton
class RemoteProgressDataSource {
  RemoteProgressDataSource(this._dio);

  final Dio _dio;

  Future<AppProgressModel> fetch() async {
    final response = await _dio.get<Map<String, dynamic>>('/progress');
    return _fromJson(response.data!);
  }

  Future<AppProgressModel> push(AppProgressModel model) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/progress',
      data: {
        'completed': model.completedLevels.map((id) => id.toString()).toList(),
        'currentLevel': model.currentLevel,
        'best': (model.best ?? const <int, LevelBestModel>{}).map(
          (levelId, best) => MapEntry(levelId.toString(), {
            'moves': best.moves,
            'timeMs': best.timeElapsedSeconds * 1000,
          }),
        ),
      },
    );
    return _fromJson(response.data!);
  }

  AppProgressModel _fromJson(Map<String, dynamic> json) {
    final completed = (json['completed'] as List<dynamic>)
        .map((id) => int.tryParse(id as String))
        .whereType<int>()
        .toList();

    final bestJson = json['best'] as Map<String, dynamic>? ?? const {};
    final best = <int, LevelBestModel>{};
    for (final entry in bestJson.entries) {
      final levelId = int.tryParse(entry.key);
      if (levelId == null) continue;
      final value = entry.value as Map<String, dynamic>;
      best[levelId] = LevelBestModel(
        moves: value['moves'] as int,
        timeElapsedSeconds: ((value['timeMs'] as int) / 1000).round(),
      );
    }

    return AppProgressModel(
      currentLevel: json['currentLevel'] as int? ?? 0,
      completedLevels: completed,
      best: best.isEmpty ? null : best,
    );
  }
}
