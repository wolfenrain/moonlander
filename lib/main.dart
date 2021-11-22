import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/map_component.dart';
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
    final image = await images.load('joystick.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 6,
      rows: 1,
    );

    ///Ensure our joystick knob is between 50 and 100 based on view height
    ///Important its based on device size not viewport size
    ///8.2 is the "magic" hud joystick factor... ;)
    final knobSize = min(max(50, canvasSize.y / 8.2), 100).toDouble();

    final joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2.all(knobSize),
      ),
      background: SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2.all(knobSize * 1.5),
      ),
      margin: const EdgeInsets.only(left: 10, bottom: 10),
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
    unawaited(add(MapComponent()));

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
