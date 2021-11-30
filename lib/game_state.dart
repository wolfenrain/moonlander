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

  /// Show or hide debug infromation of flame.
  static bool showDebugInfo = true;
}
