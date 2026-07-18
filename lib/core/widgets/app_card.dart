import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';

/// Base surface card — white fill, unified [AppRadii.md] corners and the
/// shared [AppShadows.card] sticker shadow. Replaces the inline cards that
/// each screen re-declared with drifting radii (12 / 14 / 16 / 18).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.mdAll,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// A cream-toned variant used for muted/secondary rows.
class AppCardMuted extends StatelessWidget {
  const AppCardMuted({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.cream2,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}
