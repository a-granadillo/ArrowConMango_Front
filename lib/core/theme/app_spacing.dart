import 'package:flutter/widgets.dart';

/// Spacing scale for Arrow con Mango — a 4/8-point rhythm.
///
/// Replaces the ad-hoc `SizedBox`/`EdgeInsets` literals (6/10/13/14/26/36…)
/// that were scattered across screens. Every gap and pad should come from
/// here so the layout breathes on a single, consistent grid.
abstract final class AppSpacing {
  /// 4 — hairline gaps (value ↔ label inside a stat).
  static const double xxs = 4;

  /// 8 — tight gaps (icon ↔ text, chip separators).
  static const double xs = 8;

  /// 12 — default gap between stacked controls / list rows.
  static const double sm = 12;

  /// 16 — comfortable block gap.
  static const double md = 16;

  /// 20 — page padding / section gap.
  static const double lg = 20;

  /// 24 — large section gap.
  static const double xl = 24;

  /// 32 — hero spacing.
  static const double xxl = 32;

  /// Maximum content width for menus/lists so wide (web/desktop) layouts stay
  /// centered instead of stretching edge-to-edge.
  static const double maxContentWidth = 420;

  // --- Common EdgeInsets helpers ---------------------------------------

  /// Standard page padding (`all(20)`).
  static const EdgeInsets page = EdgeInsets.all(lg);

  /// Standard vertical gap between stacked buttons (`14`→`md` normalized).
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);

  /// Header padding (`fromLTRB(20, top+20, 20, 22)` → normalized to lg/xl).
  static EdgeInsets header(double topInset) =>
      EdgeInsets.fromLTRB(lg, topInset + lg, lg, lg);
}
