import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Talks to the backend's community-levels endpoints
/// (`POST/GET/PUT /levels`, `POST /levels/:id/publish`).
///
/// Returns raw JSON maps rather than models — mapping to
/// [CreativeLevel]/[BoardState] happens in [ApiCreativeLevelRepository],
/// which needs [BoardStateMapper] (an app-layer dependency this
/// data-source-only class shouldn't reach for).
@lazySingleton
class RemoteCreativeLevelDataSource {
  RemoteCreativeLevelDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/levels',
      data: body,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/levels/$id',
      data: body,
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> publish(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/levels/$id/publish',
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> getCommunity({int? top}) async {
    final response = await _dio.get<List<dynamic>>(
      '/levels/community',
      queryParameters: {'top': ?top},
    );
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getMine() async {
    final response = await _dio.get<List<dynamic>>('/levels/mine');
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }
}
