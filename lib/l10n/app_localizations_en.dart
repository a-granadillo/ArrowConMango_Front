// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Arrow with Mango';

  @override
  String get splashTapToContinue => 'Tap to continue';

  @override
  String get menuSubtitle => 'THE TASTIEST MAZE!';

  @override
  String get menuCampaignMode => 'CAMPAIGN MODE';

  @override
  String get menuSurvivalMode => 'SURVIVAL';

  @override
  String get menuLevels => 'Levels';

  @override
  String get menuRanking => 'Ranking';

  @override
  String get menuSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlayerName => 'Player name';

  @override
  String get settingsEdit => 'Edit';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDialogPlayerName => 'Player name';

  @override
  String get settingsDialogHint => 'Your name';

  @override
  String get settingsDialogCancel => 'Cancel';

  @override
  String get settingsDialogSave => 'Save';

  @override
  String get levelSelectTitle => 'Select Level';

  @override
  String levelSelectAvailable(int unlocked, int total) {
    return '$unlocked of $total available';
  }

  @override
  String get levelSelectRetry => 'Retry';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String gameLevelLabel(int id) {
    return 'Level $id';
  }

  @override
  String gameLevelSubtitle(int id, String difficulty) {
    return 'Level $id · $difficulty';
  }

  @override
  String get gameStatArrows => 'arrows';

  @override
  String get gameStatTaps => 'taps';

  @override
  String get gameStatLevels => 'levels';

  @override
  String gameLivesLabel(int lives) {
    return 'Lives: $lives of 3';
  }

  @override
  String get gameInstructions =>
      'Tap an arrow to remove it from the board.\nIt stays blocked if another arrow crosses its exit.';

  @override
  String get gameUndo => 'Undo';

  @override
  String get gameMenuButton => 'Menu';

  @override
  String get victoryTitle => 'CONGRATULATIONS!';

  @override
  String get victoryLevelCompleted => 'LEVEL COMPLETED!';

  @override
  String victoryMangosLabel(int stars) {
    return '$stars/3 MANGOS';
  }

  @override
  String get victoryStatTaps => 'Taps';

  @override
  String get victoryStatTime => 'Time';

  @override
  String get victoryStatLevels => 'Levels';

  @override
  String get victoryStatLives => 'Lives';

  @override
  String get victoryStatMangos => 'Mangos';

  @override
  String get victoryNextLevel => 'Next level';

  @override
  String get victoryMenu => 'Menu';

  @override
  String get ratingPerfect => 'Perfect harvest! You\'re a mango master';

  @override
  String get ratingGreat => 'Great job! Almost a perfect harvest';

  @override
  String get ratingPass =>
      'Level cleared! Be faster and more precise for more mangos';

  @override
  String get defeatOhNo => 'Oh no!';

  @override
  String get defeatGameOver => 'Game Over!';

  @override
  String get defeatTimeExpired => 'Time\'s up!';

  @override
  String get defeatNoMoves => 'No moves remaining.';

  @override
  String get defeatOutOfLives => 'You ran out of lives!';

  @override
  String get defeatNoLivesMessage => 'You ran out of lives';

  @override
  String get defeatStatTaps => 'Taps';

  @override
  String get defeatStatTime => 'Time';

  @override
  String get defeatStatLevels => 'Levels';

  @override
  String get defeatStatLives => 'Lives';

  @override
  String get defeatRestart => 'Restart';

  @override
  String get defeatRetry => 'Retry';

  @override
  String get defeatMenu => 'Menu';

  @override
  String get rankingTitle => 'Leaderboard';

  @override
  String get rankingComingSoon => 'The best harvesters are coming soon 🥭';

  @override
  String rankingPlayAs(String name) {
    return 'You\'ll play as: $name';
  }

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardSubtitle => 'The best harvesters';

  @override
  String get leaderboardLinkAccount => 'Link account (Google / Apple)';

  @override
  String get leaderboardSignInComingSoon =>
      'Google/Apple sign-in — coming soon 🥭';

  @override
  String leaderboardCurrentPlayer(String name) {
    return '$name (You)';
  }

  @override
  String leaderboardLevelsSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count levels',
      one: '1 level',
    );
    return '$_temp0';
  }
}
