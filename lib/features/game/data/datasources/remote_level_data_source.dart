import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/arrow_model.dart';
import '../models/board_size_model.dart';
import '../models/board_state_model.dart';
import '../models/level_model.dart';

/// Talks to the backend's `GET /levels` endpoint.
///
/// The wire format (`arrows` at the top level, string ids) differs from
/// [LevelModel.fromJson] (`boardState: {arrows: [...]}`, int ids), so this
/// class maps fields explicitly instead of reusing that method — same
/// idiom as [RemoteProgressDataSource].
///
/// Only campaign levels (`authorId == null`) are relevant here; community
/// levels are out of scope until the Modo Creativo work.
@lazySingleton
class RemoteLevelDataSource {
  RemoteLevelDataSource(this._dio);

  final Dio _dio;

  Future<List<LevelModel>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>('/levels');
    final rows = (response.data ?? []).cast<Map<String, dynamic>>();
    return rows
        .where((json) => json['authorId'] == null)
        .map(_fromJson)
        .toList();
  }

  LevelModel _fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: int.parse(json['id'] as String),
      name: json['name'] as String,
      difficulty: json['difficulty'] as String,
      boardSize: BoardSizeModel.fromJson(
        json['boardSize'] as Map<String, dynamic>,
      ),
      boardState: BoardStateModel(
        arrows: (json['arrows'] as List<dynamic>)
            .map((a) => ArrowModel.fromJson(a as Map<String, dynamic>))
            .toList(),
      ),
    );
  }
}
