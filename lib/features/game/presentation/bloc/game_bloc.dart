import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/topologies/grid_2d_topology.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/entities/cardinal_direction.dart';
import '../../domain/entities/node_id.dart';
import '../../domain/services/collision_validator.dart';
import '../theme/mango_colors.dart';

// ============================================================================
// Eventos
// ============================================================================

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// El jugador tocó la cabeza de una flecha.
class ArrowTapped extends GameEvent {
  final String arrowId;
  const ArrowTapped(this.arrowId);

  @override
  List<Object?> get props => [arrowId];
}

/// Reinicia el nivel desde el principio.
class GameReset extends GameEvent {
  const GameReset();
}

// ============================================================================
// Estado
// ============================================================================

enum GameStatus { playing, won, lost }

/// Estado inmutable del juego.
class GameState extends Equatable {
  /// Tablero actual con las flechas que quedan.
  final BoardState board;

  /// Vidas restantes (empieza en 3).
  final int lives;

  /// Cantidad de movimientos exitosos.
  final int moveCount;

  /// Estado general de la partida.
  final GameStatus status;

  /// Último resultado: `'clear'` (camino libre) o `'blocked'` (bloqueado).
  final String? lastResult;

  /// ID de la última flecha tocada (para feedback visual).
  final String? lastArrowId;

  const GameState({
    required this.board,
    this.lives = 3,
    this.moveCount = 0,
    this.status = GameStatus.playing,
    this.lastResult,
    this.lastArrowId,
  });

  GameState copyWith({
    BoardState? board,
    int? lives,
    int? moveCount,
    GameStatus? status,
    String? lastResult,
    String? lastArrowId,
  }) {
    return GameState(
      board: board ?? this.board,
      lives: lives ?? this.lives,
      moveCount: moveCount ?? this.moveCount,
      status: status ?? this.status,
      lastResult: lastResult ?? this.lastResult,
      lastArrowId: lastArrowId ?? this.lastArrowId,
    );
  }

  @override
  List<Object?> get props =>
      [board, lives, moveCount, status, lastResult, lastArrowId];
}

// ============================================================================
// BLoC
// ============================================================================

/// BLoC que maneja la lógica del juego: tocar flechas, validar salida,
/// control de vidas y detección de victoria/derrota.
class GameBloc extends Bloc<GameEvent, GameState> {
  final CollisionValidator _validator;
  final BoardState _initialBoard; // guardado para reiniciar

  GameBloc({
    required BoardState initialBoard,
    required this._validator,
  }) : _initialBoard = initialBoard,
       super(GameState(board: initialBoard)) {
    on<ArrowTapped>(_onArrowTapped);
    on<GameReset>(_onReset);
  }

  // ── Tap en una flecha ──────────────────────────────────────────────

  Future<void> _onArrowTapped(ArrowTapped event, Emitter<GameState> emit) async {
    // Si ya ganó/perdió, ignorar taps
    if (state.status != GameStatus.playing) return;

    final arrow = state.board.getArrowById(event.arrowId);
    if (arrow == null) return; // ya fue eliminada

    final result = _validator.checkExit(arrow, state.board);

    if (result.canExit) {
      _handleClearExit(emit, arrow, event.arrowId);
    } else {
      _handleBlocked(emit, arrow, event.arrowId);
    }
  }

  void _handleClearExit(Emitter<GameState> emit, ArrowEntity arrow, String arrowId) {
    final newBoard = state.board.withoutArrow(arrow);
    final isVictory = newBoard.isEmpty;

    emit(state.copyWith(
      board: newBoard,
      moveCount: state.moveCount + 1,
      status: isVictory ? GameStatus.won : GameStatus.playing,
      lastResult: 'clear',
      lastArrowId: arrowId,
    ));
  }

  void _handleBlocked(Emitter<GameState> emit, ArrowEntity arrow, String arrowId) {
    final newLives = state.lives - 1;
    final isLost = newLives <= 0;

    emit(state.copyWith(
      lives: newLives,
      status: isLost ? GameStatus.lost : GameStatus.playing,
      lastResult: 'blocked',
      lastArrowId: arrowId,
    ));
  }

  // ── Reinicio ───────────────────────────────────────────────────────

  Future<void> _onReset(GameReset event, Emitter<GameState> emit) async {
    emit(GameState(board: _initialBoard));
  }
}

// ============================================================================
// Nivel predeterminado — datos estáticos para el demo
// ============================================================================

/// Colores de flecha extra (fuera de MangoColors).
const _purple = Color(0xFF9C27B0);
const _purpleLight = Color(0xFFCE93D8);
const _teal = Color(0xFF00897B);
const _tealLight = Color(0xFF4DB6AC);

/// Posiciones del nivel demo en formato (fila, columna), [0]=tail, último=head.
const _levelArrows = <_ArrowDef>[
  // ── A (naranja)   head(2,3)→DERECHA  ←  BLOQUEADA por G (2,6)
  _ArrowDef(
    id: 'A',
    color: MangoColors.mangoOrange,
    bodyColor: Color(0xFFFFB866),
    icon: Icons.arrow_forward,
    cells: [
      (0, 0), (0, 1), (0, 2), (0, 3), (1, 3), (2, 3),
    ],
  ),
  // ── B (verde)     head(1,5)→ARRIBA  ←  LIBRE (sale por arriba)
  _ArrowDef(
    id: 'B',
    color: MangoColors.leafGreen,
    bodyColor: Color(0xFF81C784),
    icon: Icons.arrow_upward,
    cells: [
      (0, 5), (0, 6), (1, 6), (1, 5),
    ],
  ),
  // ── C (amarillo)  head(5,5)→ARRIBA  ←  BLOQUEADA por B (1,5)
  _ArrowDef(
    id: 'C',
    color: MangoColors.mangoYellow,
    bodyColor: Color(0xFFFFCC66),
    icon: Icons.arrow_upward,
    cells: [
      (3, 4), (3, 5), (4, 5), (5, 5),
    ],
  ),
  // ── D (rojo)      head(6,1)→IZQUIERDA  ←  LIBRE (sale por izquierda)
  _ArrowDef(
    id: 'D',
    color: MangoColors.mangoRed,
    bodyColor: Color(0xFFFF8A65),
    icon: Icons.arrow_back,
    cells: [
      (4, 0), (5, 0), (6, 0), (6, 1),
    ],
  ),
  // ── E (verde oscuro)  head(4,3)→ARRIBA  ←  BLOQUEADA por A (2,3)
  _ArrowDef(
    id: 'E',
    color: MangoColors.darkLeafGreen,
    bodyColor: Color(0xFF66BB6A),
    icon: Icons.arrow_upward,
    cells: [
      (5, 2), (5, 3), (5, 4), (4, 4), (4, 3),
    ],
  ),
  // ── F (púrpura)  head(4,1)→IZQUIERDA  ←  BLOQUEADA por D (4,0)
  _ArrowDef(
    id: 'F',
    color: _purple,
    bodyColor: _purpleLight,
    icon: Icons.arrow_back,
    cells: [
      (2, 1), (2, 2), (3, 2), (4, 2), (4, 1),
    ],
  ),
  // ── G (cian)     head(6,6)→ABAJO  ←  LIBRE (sale por borde inferior)
  _ArrowDef(
    id: 'G',
    color: _teal,
    bodyColor: _tealLight,
    icon: Icons.arrow_downward,
    cells: [
      (2, 6), (3, 6), (4, 6), (5, 6), (6, 6),
    ],
  ),
];

/// Definición interna de una flecha del nivel.
class _ArrowDef {
  final String id;
  final Color color;
  final Color bodyColor;
  final IconData icon;
  final List<(int, int)> cells;

  const _ArrowDef({
    required this.id,
    required this.color,
    required this.bodyColor,
    required this.icon,
    required this.cells,
  });
}

/// Convierte [icon] a [CardinalDirection].
CardinalDirection _iconToDirection(IconData icon) {
  if (icon == Icons.arrow_forward) return CardinalDirection.right;
  if (icon == Icons.arrow_back) return CardinalDirection.left;
  if (icon == Icons.arrow_upward) return CardinalDirection.up;
  return CardinalDirection.down; // arrow_downward
}

/// Crea el [BoardState] inicial y el [CollisionValidator] para el nivel demo.
///
/// Retorna la tupla (board, validator).
(BoardState, CollisionValidator) createDemoLevel() {
  const rows = 7, cols = 7;

  final arrows = _levelArrows.map((def) {
    return ArrowEntity(
      id: def.id,
      direction: _iconToDirection(def.icon),
      occupiedNodes: def.cells
          .map((c) => Grid2DNodeId(row: c.$1, col: c.$2) as NodeId)
          .toList(),
    );
  }).toList();

  final board = BoardState(arrows: arrows);
  final topology = Grid2DTopology(rows: rows, cols: cols);
  final validator = CollisionValidator(topology);

  return (board, validator);
}
