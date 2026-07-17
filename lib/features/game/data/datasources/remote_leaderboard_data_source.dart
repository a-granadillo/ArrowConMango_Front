import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Talks to the backend's leaderboard endpoints.
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
    required String mode,
  }) async {
    await _dio.post<void>(
      '/leaderboard',
      data: {
        'levelId': levelId.toString(),
        'moves': moves,
        'timeMs': elapsedSeconds * 1000,
        'mode': mode,
      },
    );
  }

  /// String-levelId sibling of [submit], for community levels (backend
  /// UUIDs) — [submit] stays int-only so the campaign call site never has
  /// to change.
  Future<void> submitForLevel({
    required String levelId,
    required int moves,
    required int elapsedSeconds,
    required String mode,
  }) async {
    await _dio.post<void>(
      '/leaderboard',
      data: {
        'levelId': levelId,
        'moves': moves,
        'timeMs': elapsedSeconds * 1000,
        'mode': mode,
      },
    );
  }

  /// Fetches a level's own top scores plus the requesting player's row from
  /// `GET /leaderboard/:nivel`. Returns the raw `{top, me}` JSON body.
  Future<Map<String, dynamic>> fetchByLevel(
    String levelId, {
    int? top,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leaderboard/$levelId',
      queryParameters: {'top': ?top},
    );
    return response.data!;
  }

  /// Fetches the survival ranking plus the requesting player's row from
  /// `GET /leaderboard/supervivencia`. Returns the raw `{top, me}` JSON body.
  Future<Map<String, dynamic>> fetchSurvival({int? top}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/leaderboard/supervivencia',
      queryParameters: {'top': ?top},
    );
    return response.data!;
  }
}
