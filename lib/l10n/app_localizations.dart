import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Arrow con Mango'**
  String get appTitle;

  /// No description provided for @splashTapToContinue.
  ///
  /// In es, this message translates to:
  /// **'Toca para continuar'**
  String get splashTapToContinue;

  /// No description provided for @menuSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¡EL LABERINTO MÁS SABROSO!'**
  String get menuSubtitle;

  /// No description provided for @menuCampaignMode.
  ///
  /// In es, this message translates to:
  /// **'MODO CAMPAÑA'**
  String get menuCampaignMode;

  /// No description provided for @menuSurvivalMode.
  ///
  /// In es, this message translates to:
  /// **'SUPERVIVENCIA'**
  String get menuSurvivalMode;

  /// No description provided for @menuLevels.
  ///
  /// In es, this message translates to:
  /// **'Niveles'**
  String get menuLevels;

  /// No description provided for @menuRanking.
  ///
  /// In es, this message translates to:
  /// **'Ranking'**
  String get menuRanking;

  /// No description provided for @menuSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get menuSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsPlayerName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de jugador'**
  String get settingsPlayerName;

  /// No description provided for @settingsEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get settingsEdit;

  /// No description provided for @settingsSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get settingsSound;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsBoard3D.
  ///
  /// In es, this message translates to:
  /// **'Tablero 3D (demo)'**
  String get settingsBoard3D;

  /// No description provided for @settingsBoard3DSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Vista previa del renderizado por capas Z'**
  String get settingsBoard3DSubtitle;

  /// No description provided for @settingsDialogPlayerName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de jugador'**
  String get settingsDialogPlayerName;

  /// No description provided for @settingsDialogHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get settingsDialogHint;

  /// No description provided for @settingsDialogCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get settingsDialogCancel;

  /// No description provided for @settingsDialogSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get settingsDialogSave;

  /// No description provided for @levelSelectTitle.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Nivel'**
  String get levelSelectTitle;

  /// No description provided for @levelSelectAvailable.
  ///
  /// In es, this message translates to:
  /// **'{unlocked} de {total} disponibles'**
  String levelSelectAvailable(int unlocked, int total);

  /// No description provided for @levelSelectRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get levelSelectRetry;

  /// No description provided for @difficultyEasy.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get difficultyHard;

  /// No description provided for @gameLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {id}'**
  String gameLevelLabel(int id);

  /// No description provided for @gameLevelSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nivel {id} · {difficulty}'**
  String gameLevelSubtitle(int id, String difficulty);

  /// No description provided for @gameStatArrows.
  ///
  /// In es, this message translates to:
  /// **'flechas'**
  String get gameStatArrows;

  /// No description provided for @gameStatTaps.
  ///
  /// In es, this message translates to:
  /// **'toques'**
  String get gameStatTaps;

  /// No description provided for @gameStatLevels.
  ///
  /// In es, this message translates to:
  /// **'niveles'**
  String get gameStatLevels;

  /// No description provided for @gameLivesLabel.
  ///
  /// In es, this message translates to:
  /// **'Vidas: {lives} de 3'**
  String gameLivesLabel(int lives);

  /// No description provided for @gameInstructions.
  ///
  /// In es, this message translates to:
  /// **'Toca una flecha para sacarla del tablero.\nSolo queda bloqueada si otra flecha cruza su salida.'**
  String get gameInstructions;

  /// No description provided for @gameUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get gameUndo;

  /// No description provided for @gameMenuButton.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get gameMenuButton;

  /// No description provided for @victoryTitle.
  ///
  /// In es, this message translates to:
  /// **'¡ENHORABUENA!'**
  String get victoryTitle;

  /// No description provided for @victoryLevelCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡NIVEL COMPLETADO!'**
  String get victoryLevelCompleted;

  /// No description provided for @victoryMangosLabel.
  ///
  /// In es, this message translates to:
  /// **'{stars}/3 MANGOS'**
  String victoryMangosLabel(int stars);

  /// No description provided for @victoryStatTaps.
  ///
  /// In es, this message translates to:
  /// **'Toques'**
  String get victoryStatTaps;

  /// No description provided for @victoryStatTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get victoryStatTime;

  /// No description provided for @victoryStatLevels.
  ///
  /// In es, this message translates to:
  /// **'Niveles'**
  String get victoryStatLevels;

  /// No description provided for @victoryStatLives.
  ///
  /// In es, this message translates to:
  /// **'Vidas'**
  String get victoryStatLives;

  /// No description provided for @victoryStatMangos.
  ///
  /// In es, this message translates to:
  /// **'Mangos'**
  String get victoryStatMangos;

  /// No description provided for @victoryNextLevel.
  ///
  /// In es, this message translates to:
  /// **'Siguiente nivel'**
  String get victoryNextLevel;

  /// No description provided for @victoryMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get victoryMenu;

  /// No description provided for @ratingPerfect.
  ///
  /// In es, this message translates to:
  /// **'¡Cosecha perfecta! Eres un maestro del mango'**
  String get ratingPerfect;

  /// No description provided for @ratingGreat.
  ///
  /// In es, this message translates to:
  /// **'¡Muy bien! Casi una cosecha perfecta'**
  String get ratingGreat;

  /// No description provided for @ratingPass.
  ///
  /// In es, this message translates to:
  /// **'¡Nivel superado! Sé más rápido y preciso para más mangos'**
  String get ratingPass;

  /// No description provided for @defeatOhNo.
  ///
  /// In es, this message translates to:
  /// **'¡Oh no!'**
  String get defeatOhNo;

  /// No description provided for @defeatGameOver.
  ///
  /// In es, this message translates to:
  /// **'¡Game Over!'**
  String get defeatGameOver;

  /// No description provided for @defeatTimeExpired.
  ///
  /// In es, this message translates to:
  /// **'¡Se acabó el tiempo!'**
  String get defeatTimeExpired;

  /// No description provided for @defeatNoMoves.
  ///
  /// In es, this message translates to:
  /// **'No quedan movimientos posibles.'**
  String get defeatNoMoves;

  /// No description provided for @defeatOutOfLives.
  ///
  /// In es, this message translates to:
  /// **'¡Te quedaste sin vidas!'**
  String get defeatOutOfLives;

  /// No description provided for @defeatNoLivesMessage.
  ///
  /// In es, this message translates to:
  /// **'Te quedaste sin vidas'**
  String get defeatNoLivesMessage;

  /// No description provided for @defeatStatTaps.
  ///
  /// In es, this message translates to:
  /// **'Toques'**
  String get defeatStatTaps;

  /// No description provided for @defeatStatTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get defeatStatTime;

  /// No description provided for @defeatStatLevels.
  ///
  /// In es, this message translates to:
  /// **'Niveles'**
  String get defeatStatLevels;

  /// No description provided for @defeatStatLives.
  ///
  /// In es, this message translates to:
  /// **'Vidas'**
  String get defeatStatLives;

  /// No description provided for @defeatRestart.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get defeatRestart;

  /// No description provided for @defeatRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get defeatRetry;

  /// No description provided for @defeatMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get defeatMenu;

  /// No description provided for @rankingTitle.
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get rankingTitle;

  /// No description provided for @rankingComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Los mejores cosechadores llegarán pronto 🥭'**
  String get rankingComingSoon;

  /// No description provided for @rankingPlayAs.
  ///
  /// In es, this message translates to:
  /// **'Jugarás como: {name}'**
  String rankingPlayAs(String name);

  /// No description provided for @leaderboardTitle.
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Los mejores cosechadores'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardLinkAccount.
  ///
  /// In es, this message translates to:
  /// **'Vincular cuenta (Google / Apple)'**
  String get leaderboardLinkAccount;

  /// No description provided for @leaderboardSignInComingSoon.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión con Google/Apple — próximamente 🥭'**
  String get leaderboardSignInComingSoon;

  /// No description provided for @leaderboardCurrentPlayer.
  ///
  /// In es, this message translates to:
  /// **'{name} (Tú)'**
  String leaderboardCurrentPlayer(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
