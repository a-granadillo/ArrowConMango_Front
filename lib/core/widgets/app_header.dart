import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_svgs.dart';

/// Shared screen header — the rounded gradient top block used across level
/// selection, settings, leaderboard and (via [AppScreenHeader.gradient]) the
/// creative/play hubs. Replaces the near-identical private `_Header` widgets
/// and the flat Material `AppBar`s, so every screen presents the same shape.
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.gradient = AppGradients.green,
  });

  final String title;

  /// Optional secondary line under the title (e.g. "3 / 15 available").
  final Widget? subtitle;

  /// When set, a back chevron button is shown on the left.
  final VoidCallback? onBack;

  /// Optional trailing widget (usually a [MangoLogo]).
  final Widget? trailing;

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: AppSpacing.header(top),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadii.headerBottom,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            HeaderBackButton(onTap: onBack!),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMd(color: Colors.white)),
                ?subtitle,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded translucent back-chevron button used inside headers.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: AppRadii.smAll,
        ),
        child: AppSvgs.icon(AppSvgs.backChevron, 20),
      ),
    );
  }
}

/// Square-ish translucent icon button used in the in-game header HUD
/// (home / restart). Shared by the 2D / hex / 3D game screens.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({super.key, required this.svg, required this.onTap});

  final String svg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: AppRadii.smAll,
        ),
        child: AppSvgs.icon(svg, 17),
      ),
    );
  }
}
