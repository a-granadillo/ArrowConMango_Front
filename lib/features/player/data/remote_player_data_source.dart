import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Talks to the backend's `PATCH /player/me` endpoint.
@lazySingleton
class RemotePlayerDataSource {
  RemotePlayerDataSource(this._dio);

  final Dio _dio;

  Future<void> updateDisplayName(String displayName) async {
    await _dio.patch<void>(
      '/player/me',
      data: {'displayName': displayName},
    );
  }
}
