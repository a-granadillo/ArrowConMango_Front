import 'package:flutter/widgets.dart';

/// Corner-radius scale for Arrow con Mango.
///
/// Consolidates the 12/14/16/18/20/22/30/32 radii that were used
/// interchangeably across cards, chips, buttons and headers.
abstract final class AppRadii {
  /// 12 — chips, small pills, icon buttons.
  static const double sm = 12;

  /// 16 — cards, list rows, input fields.
  static const double md = 16;

  /// 20 — level tiles, headers, setting cards.
  static const double lg = 20;

  /// 22 — primary call-to-action buttons.
  static const double pill = 22;

  /// 30 — screen headers (green/orange top blocks). Kept at the existing
  /// value so unifying the three header shapes doesn't shrink the look.
  static const double header = 30;

  /// 32 — bottom sheets.
  static const double sheet = 32;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// Rounded bottom only — used by the green/orange screen headers.
  static const BorderRadius headerBottom = BorderRadius.vertical(
    bottom: Radius.circular(header),
  );

  /// Rounded top only — used by the result bottom sheet.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
