import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';

/// A full-screen scaffold whose background is the brand gradient.
///
/// Shared across screens so the app has a consistent "mango" look.
class MangoBackground extends StatelessWidget {
  const MangoBackground({
    super.key,
    required this.child,
    this.gradient,
    this.padding = const EdgeInsets.all(24),
  });

  /// Content laid on top of the gradient (inside a [SafeArea]).
  final Widget child;

  /// Optional gradient override (defaults to [AppGradients.brand]).
  final Gradient? gradient;

  /// Padding around the content.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient ?? AppGradients.brand),
        child: SafeArea(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
