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

  /// Victory gradient (green).
  static const LinearGradient victory = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.successDark, AppColors.success],
  );
}
