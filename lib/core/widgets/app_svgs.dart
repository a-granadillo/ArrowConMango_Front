import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Raw SVG icons copied from the design so the UI matches it exactly.
abstract final class AppSvgs {
  static const String _ns = 'xmlns="http://www.w3.org/2000/svg"';

  /// Trophy (Niveles button).
  static const String niveles =
      '<svg $_ns viewBox="0 0 24 24" fill="none" stroke="#6D4C2A" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M6 3h12v6a6 6 0 0 1-12 0z"/><path d="M6 5H4a2 2 0 0 0 2 4"/><path d="M18 5h2a2 2 0 0 1-2 4"/><path d="M12 15v4"/><path d="M8 21h8"/></svg>';

  /// Bar chart (Ranking button).
  static const String ranking =
      '<svg $_ns viewBox="0 0 24 24" fill="#fff">'
      '<rect x="9" y="4" width="6" height="16" rx="1"/><rect x="2" y="10" width="6" height="10" rx="1"/><rect x="16" y="13" width="6" height="7" rx="1"/></svg>';

  /// Sliders (Ajustes button).
  static const String ajustes =
      '<svg $_ns viewBox="0 0 24 24" fill="none" stroke="#F9C74F" stroke-width="2.5" stroke-linecap="round">'
      '<path d="M3 6h18"/><circle cx="9" cy="6" r="2.6" fill="#6D4C2A"/><path d="M3 13h18"/><circle cx="15" cy="13" r="2.6" fill="#6D4C2A"/><path d="M3 20h18"/><circle cx="7" cy="20" r="2.6" fill="#6D4C2A"/></svg>';

  /// Back chevron (white, for headers).
  static const String backChevron =
      '<svg $_ns viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M15 18l-6-6 6-6"/></svg>';

  /// Small lock (locked level tiles).
  static const String lock =
      '<svg $_ns viewBox="0 0 24 24" fill="none" stroke="#A0826D" stroke-width="2.5" stroke-linecap="round"><rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></svg>';

  /// Faded mango leaf used as header decoration.
  static const String leaf =
      '<svg $_ns viewBox="0 0 24 24" fill="#fff"><path d="M4 20 Q4 6 20 4 Q20 18 6 20 Q5 20 4 20 Z"/></svg>';

  /// A completed-level mini mango (cream body, green leaf) for the level tiles.
  static const String miniMango =
      '<svg $_ns viewBox="0 0 24 24"><ellipse cx="12" cy="13.5" rx="8.5" ry="7" transform="rotate(-18 12 13.5)" fill="#FFF8EE"/><path d="M15.5 6.5 Q19.5 3.5 21 6.5 Q18.5 9 15.5 7.5 Z" fill="#2E7D32"/></svg>';

  static Widget icon(String svg, double size) =>
      SvgPicture.string(svg, width: size, height: size);
}
