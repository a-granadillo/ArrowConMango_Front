import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Convenience access to [AppLocalizations] from any [BuildContext].
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
