import 'package:moonlander/database/database.dart';

/// Describes the current state of the game.
enum PlayingState {
  /// In the menu.
  paused,

  /// Lost the level.
  lost,

  /// Won the level.
  won,

  /// Playing.
  playing,
}

/// State of the game to track global infomration.
class GameState {
  /// Current playing state.
  static PlayingState playState = PlayingState.playing;

  ///Current level that is played, if null the leve is not in the DB, check seed
  static LevelData? currentLevel;

  ///Seed of the current loaded level
  static late String seed;

  ///Last score if null no new score for current level
  static int? lastScore;

  /// Show or hide debug infromation of flame.
  static bool showDebugInfo = false;

  ///Toggle sounds
  static bool playSounds = true;

  ///Our database for the complete game
  static late final MoonLanderDatabase database;
}
