import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable brand gradients extracted from the UI mockup.
abstract final class AppGradients {
  /// Main brand gradient (mango yellow → orange → dark orange).
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.mango, AppColors.primary, AppColors.primaryDark],
    stops: [0.0, 0.6, 1.0],
  );

  /// Solid-ish orange gradient for headers / buttons.
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  /// Victory / green header gradient (level selection, settings, hex/3D game,
  /// leaderboard). Directional to catch the light from the top-left.
  static const LinearGradient green = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [AppColors.successDark, AppColors.success],
  );

  /// Victory gradient (green) — vertical variant.
  static const LinearGradient victory = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.successDark, AppColors.success],
  );

  /// In-game orange header gradient (2D campaign/endless).
  static const LinearGradient gameHeader = LinearGradient(
    begin: Alignment(-0.4, -1),
    end: Alignment(0.4, 1),
    colors: [AppColors.primary, AppColors.headerOrangeEnd],
  );

  /// Primary action-button gradient (result sheets: next level / retry).
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primary, AppColors.primaryButtonEnd],
  );
}
