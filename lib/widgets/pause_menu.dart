import 'package:flutter/material.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/main.dart';

/// By using the Flutter Widgets we can handle all non-game related UI through
/// widgets.
class PauseMenu extends StatelessWidget {
  ///
  const PauseMenu({Key? key, required this.game}) : super(key: key);

  /// The reference to the game.
  final MoonlanderGame game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text(
                    _getTitle(),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                if (GameState.playState == PlayingState.paused)
                  _getButton(
                    'Resume',
                    () => game.overlays.remove('pause'),
                  ),
                _getButton(
                  'Restart',
                  () {
                    game.overlays.remove('pause');
                    game.restart();
                  },
                ),
                if (GameState.currentLevel != null)
                  _getButton(
                    'Highscorse',
                    () {
                      game.overlays.remove('pause');
                      game.overlays.add('highscore');
                    },
                  ),
                _getButton(
                  'Levels',
                  () {
                    game.overlays.remove('pause');
                    game.overlays.add('levelSelection');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getButton(
    String label,
    VoidCallback onPressed, {
    bool includeTopMargin = true,
  }) {
    final button = ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
    if (includeTopMargin) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: button,
      );
    }
    return button;
  }

  String _getTitle() {
    if (GameState.playState == PlayingState.paused) {
      return 'Pause';
    } else if (GameState.playState == PlayingState.lost) {
      return 'Game over';
    } else {
      return 'Winner Score: ${GameState.lastScore?.toStringAsFixed(0)}';
    }
  }
}
