// Throwaway smoke test for F5: exercises the REAL production classes
// (AuthInterceptor, RemoteLeaderboardDataSource, ApiLeaderboardRepository)
// against a live backend instance. Deleted after use.
//
// Run with:
//   dart run --define=API_BASE_URL=http://localhost:3000/api/v1 tool/verify_f5_smoke.dart

import 'dart:math';

import 'package:arrowconmango_front/core/network/api_client.dart';
import 'package:arrowconmango_front/core/network/auth_interceptor.dart';
import 'package:arrowconmango_front/features/game/data/datasources/remote_leaderboard_data_source.dart';
import 'package:arrowconmango_front/features/leaderboard/data/api_leaderboard_repository.dart';
import 'package:arrowconmango_front/features/player/data/auth_token_store.dart';
import 'package:arrowconmango_front/features/player/domain/guest_player.dart';
import 'package:hive/hive.dart';

String _uuidV4(Random rng) {
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) =>
      bytes.sublist(start, end).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}

Future<void> _seedGuest(Random rng, String displayName) async {
  final box = await Hive.openBox<dynamic>('smoke_${_uuidV4(rng)}');
  final tokenStore = AuthTokenStore(box: box);
  final uuid = _uuidV4(rng);
  final interceptor = AuthInterceptor(
    tokenStore: tokenStore,
    guestUuid: uuid,
    guestDisplayName: displayName,
  );
  final client = ApiClient(authInterceptor: interceptor);
  final dataSource = RemoteLeaderboardDataSource(client.dio);
  await dataSource.submit(levelId: 1, moves: 3, elapsedSeconds: 20);
  await box.close();
  // ignore: avoid_print
  print('seeded $displayName ($uuid)');
}

Future<void> main() async {
  Hive.init('build/smoke_hive');
  final rng = Random();

  await _seedGuest(rng, 'F5_Alice');
  await _seedGuest(rng, 'F5_Bob');
  await _seedGuest(rng, 'F5_Carol');

  final box = await Hive.openBox<dynamic>('smoke_reader_${_uuidV4(rng)}');
  final tokenStore = AuthTokenStore(box: box);
  final readerUuid = _uuidV4(rng);
  final interceptor = AuthInterceptor(
    tokenStore: tokenStore,
    guestUuid: readerUuid,
    guestDisplayName: 'F5_Reader',
  );
  final client = ApiClient(authInterceptor: interceptor);
  final dataSource = RemoteLeaderboardDataSource(client.dio);
  final repository = ApiLeaderboardRepository(dataSource);

  final entries = await repository.fetchTopPlayers(
    currentPlayer: GuestPlayer(uuid: readerUuid, displayName: 'F5_Reader'),
    limit: 10,
  );

  // ignore: avoid_print
  print('--- GET /leaderboard/global (top 10) ---');
  for (final e in entries) {
    // ignore: avoid_print
    print(
      '#${e.rank} ${e.displayName} mangos=${e.mangos} '
      'levelsCompleted=${e.levelsCompleted} color=0x${e.colorValue.toRadixString(16)} '
      'isMe=${e.isCurrentPlayer}',
    );
  }

  final names = entries.map((e) => e.displayName).toSet();
  final expectSeeded =
      {'F5_Alice', 'F5_Bob', 'F5_Carol'}.every(names.contains);
  final anyGuestLiteral = entries.any((e) => e.displayName == 'Guest');

  if (!expectSeeded) {
    throw StateError('FAIL: seeded display names missing from response: $names');
  }
  if (anyGuestLiteral) {
    throw StateError('FAIL: found a row literally named "Guest" — displayName not forwarded');
  }
  // ignore: avoid_print
  print('PASS: all seeded displayNames present, no literal "Guest" rows.');
}
