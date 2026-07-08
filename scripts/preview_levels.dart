import 'package:arrowconmango_front/features/game/data/level_definitions/level_definitions.dart';
import 'package:arrowconmango_front/features/game/data/models/level_model.dart';

/// Genera una representación ASCII de los niveles para previsualización.
/// 
/// Uso: dart run scripts/preview_levels.dart
void main() {
  print('=== PREVIEW DE NIVELES ===\n');
  
  for (final level in LevelDefinitions.allLevels) {
    printLevel(level);
    print('');
  }
}

void printLevel(LevelModel level) {
  print('Nivel #${level.id}: ${level.name} (${level.difficulty})');
  print('Flechas: ${level.boardState.arrows.length}');
  print('Tablero: ${level.boardSize.rows}x${level.boardSize.cols}');
  print('');

  // Crear grilla vacía usando las dimensiones del nivel
  final grid = List.generate(
    level.boardSize.rows,
    (_) => List.filled(level.boardSize.cols, '·'),
  );
  
  // Llenar grilla con flechas
  const directionSymbols = {
    'up': '↑',
    'down': '↓',
    'left': '←',
    'right': '→',
  };
  
  for (final arrow in level.boardState.arrows) {
    final symbol = directionSymbols[arrow.direction] ?? '?';
    for (final node in arrow.nodes) {
      grid[node.row][node.col] = symbol;
    }
  }
  
  // Imprimir grilla
  for (final row in grid) {
    print('  ${row.join(' ')}');
  }
  
  print('');
  print('Leyenda: ↑↓←→ = flechas, · = celda vacía');
  print('-' * 60);
}
