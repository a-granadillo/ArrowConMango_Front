import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Talks to the backend's `POST /leaderboard` endpoint.
///
/// Time is sent to the wire in **milliseconds**; the game domain tracks
/// elapsed time in seconds ([Score.timeElapsed]), so the conversion happens
/// here at the datasource boundary rather than pushing a unit change into
/// the domain.
@lazySingleton
class RemoteLeaderboardDataSource {
  RemoteLeaderboardDataSource(this._dio);

  final Dio _dio;

  Future<void> submit({
    required int levelId,
    required int moves,
    required int elapsedSeconds,
  }) async {
    await _dio.post<void>(
      '/leaderboard',
      data: {
        'levelId': levelId.toString(),
        'moves': moves,
        'timeMs': elapsedSeconds * 1000,
      },
    );
  }

  /// Fetches the global ranking (by total mango stars) from
  /// `GET /leaderboard/global`.
  Future<List<Map<String, dynamic>>> fetchGlobal({required int top}) async {
    final response = await _dio.get<List<dynamic>>(
      '/leaderboard/global',
      queryParameters: {'top': top},
    );
    return (response.data ?? [])
        .cast<Map<String, dynamic>>();
  }
}
