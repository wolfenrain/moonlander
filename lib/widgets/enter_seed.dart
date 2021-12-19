import 'package:flutter/material.dart';
import 'package:moonlander/main.dart';

///Show a screen to enter a seed to start playing it
class EnterSeed extends StatelessWidget {
  ///Show a screen to enter a seed to start playing it
  EnterSeed(this._game, {Key? key}) : super(key: key);
  final MoonlanderGame _game;
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
      _game.overlays.remove('enterSeed');
      _game.overlays.add('pause');
    } else {
      _game.loadLevel(seed);
      _game.overlays.remove('enterSeed');
    }
  }
}
