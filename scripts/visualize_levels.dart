import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

/// Genera visualización ASCII de los niveles para validar reglas estructurales.
void main() {
  print('=== VISUALIZACIÓN DE NIVELES ===\n');
  
  // Mostrar solo los primeros 3 niveles de cada dificultad para análisis
  print('--- EASY LEVELS (1-3) ---\n');
  for (var i = 0; i < 3 && i < LevelDefinitions.easyLevels.length; i++) {
    _renderLevel(LevelDefinitions.easyLevels[i]);
  }
  
  print('\n--- MEDIUM LEVELS (6-8) ---\n');
  for (var i = 0; i < 3 && i < LevelDefinitions.mediumLevels.length; i++) {
    _renderLevel(LevelDefinitions.mediumLevels[i]);
  }
  
  print('\n--- HARD LEVELS (11-13) ---\n');
  for (var i = 0; i < 3 && i < LevelDefinitions.hardLevels.length; i++) {
    _renderLevel(LevelDefinitions.hardLevels[i]);
  }
}

void _renderLevel(LevelModel level) {
  print('Level ${level.id}: ${level.name} (${level.difficulty})');
  print('Board: ${level.boardSize.rows}x${level.boardSize.cols}');
  print('Arrows: ${level.boardState.arrows.length}');
  print('');
  
  // Crear grilla vacía
  final grid = List.generate(
    level.boardSize.rows,
    (_) => List.filled(level.boardSize.cols, '·'),
  );
  
  // Mapear símbolos de dirección
  const dirSymbols = {
    'up': '↑',
    'down': '↓',
    'left': '←',
    'right': '→',
  };
  
  // Rellenar grilla con flechas
  for (final arrow in level.boardState.arrows) {
    final symbol = dirSymbols[arrow.direction] ?? '?';
    for (final node in arrow.nodes) {
      if (node.row >= 0 && node.row < level.boardSize.rows &&
          node.col >= 0 && node.col < level.boardSize.cols) {
        grid[node.row][node.col] = symbol;
      }
    }
  }
  
  // Imprimir grilla
  for (final row in grid) {
    print('  ${row.join(' ')}');
  }
  
  // Análisis de trayectorias
  print('');
  print('  Análisis de trayectorias:');
  
  var singleSegment = 0;
  var multiSegment = 0;
  
  for (final arrow in level.boardState.arrows) {
    if (arrow.nodes.length == 1) {
      singleSegment++;
    } else {
      multiSegment++;
    }
  }
  
  print('  - Segmentos simples (1 nodo): $singleSegment');
  print('  - Segmentos múltiples (2-3 nodos): $multiSegment');
  print('  - Giros de 90°: NO DETECTADOS (modelo actual no soporta giros)');
  print('  - Ancho constante: N/A (modelo actual usa celdas discretas)');
  print('');
  print('  ' + '─' * 60);
  print('');
}
