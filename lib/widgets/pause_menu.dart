import 'package:flutter/material.dart';
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
    return GestureDetector(
      onTap: () => game.overlays.remove('pause'),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Center(
                  child: Text(
                    'Pause',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => game.overlays.remove('pause'),
                  child: const Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('pause');
                    game.restart();
                  },
                  child: const Text('Restart'),
                ),
                ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('pause');
                    game.overlays.add('levels');
                  },
                  child: const Text('Levels'),
                ),
                ElevatedButton(
                  onPressed: () => game.overlays.remove('pause'),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
