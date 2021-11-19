import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/circle_component.dart';
import 'package:moonlander/components/pause_component.dart';
import 'package:moonlander/components/rocket_component.dart';
import 'package:moonlander/widgets/pause_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();

  final game = MoonlanderGame();

  runApp(
    MaterialApp(
      home: GameWidget(
        game: game,
        //Work in progress loading screen on game start
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
        //Work in progress error handling
        errorBuilder: (context, ex) {
          //Print the error in th dev console
          debugPrint(ex.toString());
          return const Center(
            child: Text('Sorry, something went wrong. Reload me'),
          );
        },
        overlayBuilderMap: {
          'pause': (context, MoonlanderGame game) => PauseMenu(game: game),
        },
      ),
    ),
  );
}

/// This class encapulates the whole game.
class MoonlanderGame extends FlameGame
    with
        HasCollidables,
        HasTappableComponents,
        HasKeyboardHandlerComponents,
        HasDraggableComponents {
  /// Depending on the active overlay state we turn of the engine or not.
  void onOverlayChanged() {
    if (overlays.isActive('pause')) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  @override
  bool get debugMode => kDebugMode;

  /// Restart the current level.
  void restart() {
    // TODO: Implement restart of current level.
  }

  @override
  void onMount() {
    overlays.addListener(onOverlayChanged);
    super.onMount();
  }

  @override
  void onRemove() {
    overlays.removeListener(onOverlayChanged);
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();

    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 40, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    unawaited(
      add(
        RocketComponent(
          position: size / 2,
          size: Vector2(32, 48),
          joystick: joystick,
        ),
      ),
    );
    unawaited(add(joystick));

    unawaited(
      add(
        PauseComponent(
          margin: const EdgeInsets.all(5),
          sprite: await Sprite.load('PauseButton.png'),
          spritePressed: await Sprite.load('PauseButtonInvert.png'),
          onPressed: () {
            if (overlays.isActive('pause')) {
              overlays.remove('pause');
            } else {
              overlays.add('pause');
            }
          },
        ),
      ),
    );

    overlays.addListener(onOverlayChanged);
    return super.onLoad();
  }
}
