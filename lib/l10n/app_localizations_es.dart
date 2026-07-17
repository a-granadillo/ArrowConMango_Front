// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Arrow con Mango';

  @override
  String get splashTapToContinue => 'Toca para continuar';

  @override
  String get menuSubtitle => '¡EL LABERINTO MÁS SABROSO!';

  @override
  String get menuPlay => 'JUGAR';

  @override
  String get menuCampaignMode => 'MODO CAMPAÑA';

  @override
  String get menuSurvivalMode => 'SUPERVIVENCIA';

  @override
  String get menuLevels => 'Niveles';

  @override
  String get menuRanking => 'Ranking';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPlayerName => 'Nombre de jugador';

  @override
  String get settingsEdit => 'Editar';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsDialogPlayerName => 'Nombre de jugador';

  @override
  String get settingsDialogHint => 'Tu nombre';

  @override
  String get settingsDialogCancel => 'Cancelar';

  @override
  String get settingsDialogSave => 'Guardar';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String settingsSignedInAs(String username) {
    return 'Sesión iniciada como $username';
  }

  @override
  String get settingsPlayingAsGuest => 'Jugando como invitado';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsSignIn => 'Iniciar sesión / Crear cuenta';

  @override
  String get authGateTitle => '¡Bienvenido!';

  @override
  String get authGateSubtitle => 'Elige cómo quieres jugar';

  @override
  String get authGateCreateAccount => 'Crear cuenta';

  @override
  String get authGateSignIn => 'Iniciar sesión';

  @override
  String get authGatePlayAsGuest => 'Jugar como invitado';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authUsernameLabel => 'Nombre de jugador';

  @override
  String get authLoginTitle => 'Iniciar sesión';

  @override
  String get authLoginSubmit => 'Entrar';

  @override
  String get authRegisterTitle => 'Crear cuenta';

  @override
  String get authRegisterSubmit => 'Registrarme';

  @override
  String get authValidationEmailRequired => 'Ingresa un correo válido';

  @override
  String get authValidationPasswordTooShort => 'Mínimo 6 caracteres';

  @override
  String get authValidationUsernameTooShort => 'Mínimo 2 caracteres';

  @override
  String get authMigratingProgress => 'Sincronizando tu progreso...';

  @override
  String get levelSelectTitle => 'Seleccionar Nivel';

  @override
  String levelSelectAvailable(int unlocked, int total) {
    return '$unlocked de $total disponibles';
  }

  @override
  String get levelSelectRetry => 'Reintentar';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String gameLevelLabel(int id) {
    return 'Nivel $id';
  }

  @override
  String gameLevelSubtitle(int id, String difficulty) {
    return 'Nivel $id · $difficulty';
  }

  @override
  String get gameStatArrows => 'flechas';

  @override
  String get gameStatTaps => 'toques';

  @override
  String get gameStatLevels => 'niveles';

  @override
  String gameLivesLabel(int lives) {
    return 'Vidas: $lives de 3';
  }

  @override
  String get gameInstructions =>
      'Toca una flecha para sacarla del tablero.\nSolo queda bloqueada si otra flecha cruza su salida.';

  @override
  String get gameUndo => 'Deshacer';

  @override
  String get gameMenuButton => 'Menú';

  @override
  String get victoryTitle => '¡ENHORABUENA!';

  @override
  String get victoryLevelCompleted => '¡NIVEL COMPLETADO!';

  @override
  String victoryMangosLabel(int stars) {
    return '$stars/3 MANGOS';
  }

  @override
  String get victoryStatTaps => 'Toques';

  @override
  String get victoryStatTime => 'Tiempo';

  @override
  String get victoryStatLevels => 'Niveles';

  @override
  String get victoryStatLives => 'Vidas';

  @override
  String get victoryStatMangos => 'Mangos';

  @override
  String get victoryNextLevel => 'Siguiente nivel';

  @override
  String get victoryMenu => 'Menú';

  @override
  String get ratingPerfect => '¡Cosecha perfecta! Eres un maestro del mango';

  @override
  String get ratingGreat => '¡Muy bien! Casi una cosecha perfecta';

  @override
  String get ratingPass =>
      '¡Nivel superado! Sé más rápido y preciso para más mangos';

  @override
  String get defeatOhNo => '¡Oh no!';

  @override
  String get defeatGameOver => '¡Game Over!';

  @override
  String get defeatTimeExpired => '¡Se acabó el tiempo!';

  @override
  String get defeatNoMoves => 'No quedan movimientos posibles.';

  @override
  String get defeatOutOfLives => '¡Te quedaste sin vidas!';

  @override
  String get defeatNoLivesMessage => 'Te quedaste sin vidas';

  @override
  String get defeatStatTaps => 'Toques';

  @override
  String get defeatStatTime => 'Tiempo';

  @override
  String get defeatStatLevels => 'Niveles';

  @override
  String get defeatStatLives => 'Vidas';

  @override
  String get defeatRestart => 'Reiniciar';

  @override
  String get defeatRetry => 'Reintentar';

  @override
  String get defeatMenu => 'Menú';

  @override
  String get rankingTitle => 'Clasificación';

  @override
  String get rankingComingSoon => 'Los mejores cosechadores llegarán pronto 🥭';

  @override
  String rankingPlayAs(String name) {
    return 'Jugarás como: $name';
  }

  @override
  String get leaderboardTitle => 'Clasificación';

  @override
  String get leaderboardSubtitle => 'Los mejores cosechadores';

  @override
  String leaderboardCurrentPlayer(String name) {
    return '$name (Tú)';
  }

  @override
  String leaderboardLevelsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niveles',
      one: '1 nivel',
    );
    return '$_temp0';
  }

  @override
  String leaderboardMovesSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
    );
    return '$_temp0';
  }

  @override
  String leaderboardRunsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardTabByLevel => 'Por Nivel';

  @override
  String get leaderboardTabSurvival => 'Supervivencia';

  @override
  String leaderboardSelectLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get leaderboardYourPosition => 'Tu posición';

  @override
  String get leaderboardEmptyByLevel =>
      'Nadie ha completado este nivel todavía.';

  @override
  String get leaderboardEmptySurvival =>
      'Nadie ha jugado Supervivencia todavía.';
}
