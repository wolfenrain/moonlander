import 'package:flutter/material.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/main.dart';

class EnterSeed extends StatelessWidget {
  final MoonlanderGame game;
  EnterSeed(this.game, {Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Material(
            child: Container(
              width: 320,
              height: 160,
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New seed',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'New seed'),
                    onFieldSubmitted: _loadLevel,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 15)),
                  ElevatedButton(
                    onPressed: () {
                      _loadLevel(_controller.value.text);
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void _loadLevel(String seed) {
    if (seed.isEmpty) {
      game.overlays.remove('enterSeed');
      game.overlays.add('pause');
    } else {
      game.loadLevel(seed);
      game.overlays.remove('enterSeed');
    }
  }
}
