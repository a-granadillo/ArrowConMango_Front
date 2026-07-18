// Exports the 15 campaign levels to a frozen JSON artifact, in the wire
// shape the backend's LevelDefinition redesign (F6) expects:
//   {id, name, difficulty, boardSize:{rows,cols},
//    arrows:[{id, startNode:{row,col}, trajectory:{segments:[...]}, isSwitchable}],
//    rules, version, authorId}
//
// Campaign levels have no author (authorId: null) and use the default
// rules used by campaign play today (no time limit, no mistake cap).
//
// This is checked in as assets/levels/campaign_levels.json — the frozen
// artifact both the backend seed and the offline frontend fallback are
// meant to match byte-for-byte. Re-run and re-freeze only when the
// generator or the level configs intentionally change.
//
// Run with: dart run tool/export_levels.dart

import 'dart:convert';
import 'dart:io';

import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

Map<String, dynamic> _toWireFormat(LevelModel level) {
  return {
    'id': level.id.toString(),
    'name': level.name,
    'difficulty': level.difficulty,
    'boardSize': level.boardSize.toJson(),
    'arrows': level.boardState.arrows.map((a) => a.toJson()).toList(),
    'rules': const <String, dynamic>{},
    'version': 1,
    'authorId': null,
  };
}

void main() {
  final levels = LevelDefinitions.campaignLevels.map(_toWireFormat).toList();
  final encoder = const JsonEncoder.withIndent('  ');
  final json = encoder.convert(levels);

  final file = File('assets/levels/campaign_levels.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('$json\n');

  // ignore: avoid_print
  print('Exported ${levels.length} levels to ${file.path}');
}
