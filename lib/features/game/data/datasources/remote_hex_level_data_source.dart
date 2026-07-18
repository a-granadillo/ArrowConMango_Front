import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Talks to the backend's `GET /levels?shape=hex` endpoint.
///
/// Returns raw JSON maps rather than models — mapping to [HexLevel] happens
/// in [HexLevelRepository], which needs [HexTopology] to walk each arrow's
/// trajectory into occupied nodes (an app/data-layer concern this
/// datasource-only class shouldn't reach for).
@lazySingleton
class RemoteHexLevelDataSource {
  RemoteHexLevelDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await _dio.get<List<dynamic>>(
      '/levels',
      queryParameters: {'shape': 'hex'},
    );
    return (response.data ?? []).cast<Map<String, dynamic>>();
  }
}
