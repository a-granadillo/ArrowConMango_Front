import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Primary gradient action button used in result sheets (next level / retry).
///
/// Consolidates the `GestureDetector`+`Container` gradient button that was
/// inlined in [VictoryScreen]/[DefeatScreen] and re-declared as
/// `_PrimaryActionButton` in the hex/3D game screens.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryButton,
          borderRadius: AppRadii.mdAll,
          boxShadow: AppShadows.buttonStrong,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            20,
            color: Colors.white,
          ).copyWith(letterSpacing: .5),
        ),
      ),
    );
  }
}

/// Secondary "menu" button paired with [PrimaryActionButton] in result sheets.
class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: AppColors.cream2,
        foregroundColor: AppColors.textMuted,
        side: const BorderSide(color: AppColors.border, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
        textStyle: AppTypography.body(15, weight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

/// A menu(secondary) + primary action pair as a single 1:2 row, the layout
/// shared by victory/defeat/hex/3D result sheets.
class ResultActionRow extends StatelessWidget {
  const ResultActionRow({
    super.key,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SecondaryActionButton(
            label: secondaryLabel,
            onTap: onSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: PrimaryActionButton(label: primaryLabel, onTap: onPrimary),
        ),
      ],
    );
  }
}
