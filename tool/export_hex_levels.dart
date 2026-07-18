// Exports the 5 hexagonal-mode catalogue levels ([HexLevels.all] — the same
// deterministic, provably-solvable generator the offline fallback uses) to a
// frozen JSON artifact, in the wire shape the backend's LevelDefinition
// expects:
//   {id, name, difficulty, shape:'hex', boardSize:{radius},
//    arrows:[{id, startNode:{q,r}, trajectory:{segments:[...]}, isSwitchable}],
//    rules, version, authorId}
//
// This is checked in as assets/levels/hexagonal_levels.json — the frozen
// artifact both the backend seed and the offline frontend fallback are meant
// to match. Re-run and re-freeze (then re-copy into the backend's
// src/infrastructure/seed-data/hexagonal-levels.json, mirroring how
// campaign_levels.json is handled) only when the generator or the level
// configs in hex_levels.dart intentionally change.
//
// Run with: dart run tool/export_hex_levels.dart

import 'dart:convert';
import 'dart:io';

import 'package:arrowconmango_front/features/game/data/level_definitions/hex_levels.dart';
import 'package:arrowconmango_front/features/game/data/models/mappers/hex_arrow_mapper.dart';
import 'package:arrowconmango_front/features/game/domain/entities/hex_level.dart';

Map<String, dynamic> _toWireFormat(HexLevel level) {
  return {
    'id': level.id,
    'name': level.name,
    'difficulty': level.difficulty,
    'shape': 'hex',
    'boardSize': {'radius': level.radius},
    'arrows':
        level.templateBoard.arrows.map(HexArrowMapper.toJson).toList(),
    'rules': {
      'timeLimitSeconds': level.timeLimitSeconds,
      'maxMistakes': level.maxMistakes,
      'allowRotation': true,
    },
    'version': 1,
    'authorId': null,
  };
}

void main() {
  final levels = HexLevels.all.map(_toWireFormat).toList();
  final encoder = const JsonEncoder.withIndent('  ');
  final json = encoder.convert(levels);

  final file = File('assets/levels/hexagonal_levels.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('$json\n');

  // ignore: avoid_print
  print('Exported ${levels.length} levels to ${file.path}');
}
