import 'package:dio/dio.dart';

import '../models/app_progress_model.dart';

/// Talks to the backend's `/progress` endpoint.
///
/// The wire format (`completed`/`best`/`currentLevel`, level IDs as
/// strings) differs from [AppProgressModel.toJson]/`fromJson`
/// (`completedLevels`/`scores`, level IDs as ints), so this class maps
/// fields explicitly instead of reusing those methods.
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
        'best': const <String, dynamic>{},
      },
    );
    return _fromJson(response.data!);
  }

  AppProgressModel _fromJson(Map<String, dynamic> json) {
    final completed = (json['completed'] as List<dynamic>)
        .map((id) => int.parse(id as String))
        .toList();
    return AppProgressModel(
      currentLevel: json['currentLevel'] as int? ?? 0,
      completedLevels: completed,
      scores: null,
    );
  }
}
