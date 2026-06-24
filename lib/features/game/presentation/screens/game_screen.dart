import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/topologies/grid_2d_topology.dart';
import '../../domain/entities/arrow_entity.dart';
import '../../domain/entities/board_state.dart';
import '../../domain/entities/node_id.dart';
import '../bloc/game_bloc.dart';
import '../theme/mango_colors.dart';

// ============================================================================
// Colores para renderizar cada flecha (solo presentación)
// ============================================================================

const _arrowColorMap = <String, (Color full, Color body)>{
  'A': (MangoColors.mangoOrange, Color(0xFFFFB866)),
  'B': (MangoColors.leafGreen, Color(0xFF81C784)),
  'C': (MangoColors.mangoYellow, Color(0xFFFFCC66)),
  'D': (MangoColors.mangoRed, Color(0xFFFF8A65)),
  'E': (MangoColors.darkLeafGreen, Color(0xFF66BB6A)),
  'F': (Color(0xFF9C27B0), Color(0xFFCE93D8)),
  'G': (Color(0xFF00897B), Color(0xFF4DB6AC)),
};

const _arrowHeadIcons = <String, IconData>{
  'A': Icons.arrow_forward, // head(2,3)→DERECHA  bloqueada
  'B': Icons.arrow_upward,   // head(1,5)→ARRIBA  libre ✓
  'C': Icons.arrow_upward,   // head(5,5)→ARRIBA  bloqueada
  'D': Icons.arrow_back,     // head(6,1)→IZQUIERDA  libre ✓
  'E': Icons.arrow_upward,   // head(4,3)→ARRIBA  bloqueada
  'F': Icons.arrow_back,     // head(4,1)→IZQUIERDA  bloqueada
  'G': Icons.arrow_downward, // head(6,6)→ABAJO  libre ✓
};

// ============================================================================
// Pantalla principal del juego
// ============================================================================

/// Pantalla del juego con BLoC — nivel demo totalmente jugable.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final (board, validator) = createDemoLevel();

    return BlocProvider(
      create: (_) => GameBloc(initialBoard: board, validator: validator),
      child: const _GameBody(),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocListener<GameBloc, GameState>(
        listenWhen: (prev, current) =>
            current.lastResult == 'blocked' && prev.lastResult != 'blocked',
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚫 ¡Camino bloqueado! Perdés una vida.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Column(
          children: [
            const _GameInfoBar(),
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MangoColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MangoColors.mangoYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const _SnakeBoard(),
                ),
              ),
            ),
            const _ControlButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Nivel 1'),
      actions: [
        BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Icon(
                    i < state.lives ? Icons.favorite : Icons.favorite_border,
                    color: MangoColors.mangoRed,
                    size: 22,
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ============================================================================
// Barra de información
// ============================================================================

class _GameInfoBar extends StatelessWidget {
  const _GameInfoBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: MangoColors.softCream,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                icon: Icons.touch_app,
                label: 'Movimientos',
                value: '${state.moveCount}',
              ),
              _InfoItem(
                icon: Icons.near_me,
                label: 'Flechas',
                value: '${state.board.arrowCount}',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: MangoColors.mangoOrange, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: MangoColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: MangoColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

// ============================================================================
// Tablero con serpientes
// ============================================================================

class _SnakeBoard extends StatelessWidget {
  const _SnakeBoard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.status != GameStatus.playing) {
          return _buildOverlay(state.status, context);
        }
        return _buildGrid(context, state.board);
      },
    );
  }

  Widget _buildGrid(BuildContext context, BoardState board) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const size = 7;
        const gapTotal = size * 2;

        final cellFromW = (constraints.maxWidth - gapTotal) / size;
        final cellFromH = (constraints.maxHeight - gapTotal) / size;
        final cellSize = cellFromW < cellFromH ? cellFromW : cellFromH;
        final gridPixelSize = size * cellSize + gapTotal;

        return Center(
          child: SizedBox(
            width: gridPixelSize,
            height: gridPixelSize,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(size, (row) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(size, (col) {
                    return _buildCell(context, board, row, col, cellSize);
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    BoardState board,
    int row,
    int col,
    double size,
  ) {
    final node = Grid2DNodeId(row: row, col: col);
    final arrow = board.getArrowAtNode(node);

    if (arrow == null) {
      return _EmptyCell(size: size);
    }

    final isHead = arrow.headNode == node;
    final colors = _arrowColorMap[arrow.id] ??
        (MangoColors.mangoOrange, Color(0xFFFFB866));

    if (isHead) {
      return GestureDetector(
        onTap: () =>
            context.read<GameBloc>().add(ArrowTapped(arrow.id)),
        child: _SnakeCell(
          size: size,
          color: colors.$1,
          bodyColor: colors.$2,
          isHead: true,
          headIcon: _arrowHeadIcons[arrow.id] ?? Icons.arrow_forward,
          connectUp: _isConnected(board, arrow, node, row - 1, col),
          connectDown: _isConnected(board, arrow, node, row + 1, col),
          connectLeft: _isConnected(board, arrow, node, row, col - 1),
          connectRight: _isConnected(board, arrow, node, row, col + 1),
        ),
      );
    }

    return _SnakeCell(
      size: size,
      color: colors.$1,
      bodyColor: colors.$2,
      isHead: false,
      connectUp: _isConnected(board, arrow, node, row - 1, col),
      connectDown: _isConnected(board, arrow, node, row + 1, col),
      connectLeft: _isConnected(board, arrow, node, row, col - 1),
      connectRight: _isConnected(board, arrow, node, row, col + 1),
    );
  }

  bool _isConnected(
    BoardState board,
    ArrowEntity arrow,
    NodeId node,
    int nr,
    int nc,
  ) {
    if (nr < 0 || nr >= 7 || nc < 0 || nc >= 7) return false;
    final neighbor = board.getArrowAtNode(Grid2DNodeId(row: nr, col: nc));
    return neighbor?.id == arrow.id;
  }

  // ── Overlay de victoria / game over ───────────────────────────────

  Widget _buildOverlay(GameStatus status, BuildContext context) {
    final isWin = status == GameStatus.won;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWin ? Icons.emoji_events : Icons.mood_bad,
            size: 80,
            color: isWin ? MangoColors.mangoYellow : MangoColors.mangoRed,
          ),
          const SizedBox(height: 16),
          Text(
            isWin ? '¡VICTORIA!' : 'GAME OVER',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isWin ? MangoColors.mangoYellow : MangoColors.mangoRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isWin ? '¡Completaste el nivel!' : 'Te quedaste sin vidas',
            style: const TextStyle(
              fontSize: 16,
              color: MangoColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<GameBloc>().add(const GameReset()),
            icon: const Icon(Icons.refresh),
            label: const Text('REINTENTAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MangoColors.mangoOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Celdas del tablero
// ============================================================================

class _SnakeCell extends StatelessWidget {
  final double size;
  final Color color;
  final Color bodyColor;
  final bool isHead;
  final IconData? headIcon;
  final bool connectUp;
  final bool connectDown;
  final bool connectLeft;
  final bool connectRight;

  const _SnakeCell({
    required this.size,
    required this.color,
    required this.bodyColor,
    required this.isHead,
    this.headIcon,
    required this.connectUp,
    required this.connectDown,
    required this.connectLeft,
    required this.connectRight,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.only(
      topLeft:
          connectUp || connectLeft ? Radius.zero : const Radius.circular(6),
      topRight:
          connectUp || connectRight ? Radius.zero : const Radius.circular(6),
      bottomLeft:
          connectDown || connectLeft ? Radius.zero : const Radius.circular(6),
      bottomRight:
          connectDown || connectRight ? Radius.zero : const Radius.circular(6),
    );

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isHead ? color : bodyColor,
        borderRadius: borderRadius,
        border: isHead ? Border.all(color: color, width: 2) : null,
      ),
      child: isHead && headIcon != null
          ? Icon(headIcon, color: Colors.white, size: size * 0.6)
          : null,
    );
  }
}

class _EmptyCell extends StatelessWidget {
  final double size;

  const _EmptyCell({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: MangoColors.cardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x20FF8C00), width: 0.5),
      ),
    );
  }
}

// ============================================================================
// Botones de control
// ============================================================================

class _ControlButtons extends StatelessWidget {
  const _ControlButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                context.read<GameBloc>().add(const GameReset()),
            icon: const Icon(Icons.refresh),
            label: const Text('REINICIAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MangoColors.mangoOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
