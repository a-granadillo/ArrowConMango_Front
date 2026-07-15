import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svgs.dart';
import '../../../../core/widgets/mango_logo.dart';
import '../widgets/arrow_color_assigner.dart';
import '../widgets/three_d/board_3d_layers_widget.dart';
import '../widgets/three_d/board_3d_samples.dart';

/// Standalone demo for issue #44 (Z-Layer rendering with ghosting for 3D
/// levels).
///
/// Not part of the game flow — real 3D levels are tracked separately in
/// issue #43 (3D domain topology), which this screen intentionally does not
/// depend on. Reachable from Settings so the widget kit can be reviewed
/// without wiring it into gameplay.
class Board3DDemoScreen extends StatefulWidget {
  const Board3DDemoScreen({super.key});

  @override
  State<Board3DDemoScreen> createState() => _Board3DDemoScreenState();
}

class _Board3DDemoScreenState extends State<Board3DDemoScreen> {
  final ArrowColorAssigner _colors = ArrowColorAssigner();

  void _onArrowTap(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tocaste la flecha "$id"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Toca los chips para cambiar de capa Z. Las flechas de las '
                    'capas vecinas se ven atenuadas como referencia.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Board3DLayersWidget(
                    model: Board3DSamples.demo,
                    colorOf: _colors.colorOf,
                    onArrowTap: _onArrowTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppSvgs.icon(AppSvgs.backChevron, 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tablero 3D (demo)',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const MangoLogo(size: 36, leaf: AppColors.mango),
        ],
      ),
    );
  }
}
