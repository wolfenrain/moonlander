import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/audio_player.dart';
import 'package:moonlander/components/map_component.dart';
import 'package:moonlander/components/pause_component.dart';
import 'package:moonlander/components/rocket_component.dart';
import 'package:moonlander/components/rocket_info.dart';
import 'package:moonlander/database/database.dart';
import 'package:moonlander/fixed_vertical_resolution_viewport.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/widgets/levels.dart';
import 'package:moonlander/widgets/pause_menu.dart';
import 'package:path/path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  GameState.database = MoonLanderDatabase();
  GameState.seed = 'FlameRocks';
  final game = MoonlanderGame();

  runApp(
    MaterialApp(
      theme: ThemeData(
        ///From here https://www.dafont.com/de/aldo-the-apache.font
        fontFamily: 'AldotheApache',
      ),
      home: GameWidget(
        game: game,
        //Work in progress loading screen on game start
        loadingBuilder: (context) => const Material(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        //Work in progress error handling
        errorBuilder: (context, ex) {
          //Print the error in th dev console
          debugPrint(ex.toString());
          return const Material(
            child: Center(
              child: Text('Sorry, something went wrong. Reload me'),
            ),
          );
        },
        overlayBuilderMap: {
          'pause': (context, MoonlanderGame game) => PauseMenu(game: game),
          'levelSelection': (context, MoonlanderGame game) => LevelSelection(
                game,
              ),
        },
      ),
    ),
  );
}

/// This class encapulates the whole game.
class MoonlanderGame extends FlameGame
    with
        HasCollidables,
        HasTappables,
        HasKeyboardHandlerComponents,
        HasDraggables {
  ///Interface to play audio
  late final MoonLanderAudioPlayer audioPlayer;

  late final RocketComponent _rocket;

  /// Depending on the active overlay state we turn of the engine or not.
  void onOverlayChanged() {
    if (overlays.value.isNotEmpty) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  @override
  bool get debugMode => GameState.showDebugInfo;

  /// Restart the current level.
  void restart() {
    // TODO(wolfen): Implement restart of current level.
    GameState.playState = PlayingState.playing;
    (children.firstWhere((child) => child is RocketComponent)
            as RocketComponent)
        .reset();
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
    camera.viewport = FixedVerticalResolutionViewport(800);
    //Init and load the audio assets
    audioPlayer = MoonLanderAudioPlayer();
    await audioPlayer.loadAssets();

    ///Ensure our joystick knob is between 50 and 100 based on view height
    ///Important its based on device size not viewport size
    ///8.2 is the "magic" hud joystick factor... ;)
    final knobSize = min(max(50, size.y / 8.2), 100).toDouble();

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
    _rocket = RocketComponent(
      position: size / 2,
      size: Vector2(32, 48),
      joystick: joystick,
    );

    camera.followComponent(_rocket);

    unawaited(add(_rocket));
    unawaited(add(joystick));
    unawaited(add(MapComponent()));
    unawaited(add(RocketInfo(_rocket)));
    unawaited(
      add(
        PauseComponent(
          margin: const EdgeInsets.only(
            top: 10,
            left: 5,
          ),
          sprite: await Sprite.load('PauseButton.png'),
          spritePressed: await Sprite.load('PauseButtonInvert.png'),
          onPressed: () {
            if (overlays.isActive('levelSelection')) {
              return;
            }
            if (overlays.isActive('pause')) {
              overlays.remove('pause');
              if (GameState.playState == PlayingState.paused) {
                GameState.playState = PlayingState.playing;
              }
            } else {
              if (GameState.playState == PlayingState.playing) {
                GameState.playState = PlayingState.paused;
              }

              overlays.add('pause');
            }
          },
        ),
      ),
    );
    overlays.addListener(onOverlayChanged);
    return super.onLoad();
  }

  ///Load the level based on the given seed
  Future<void> loadLevel(String seed) async {
    restart();
    GameState.seed = seed;
    children.removeWhere((element) => element is MapComponent);
    await add(MapComponent(mapSeed: seed.hashCode));
    _removeAnyOverlay();
  }

  void _removeAnyOverlay() {
    for (final activeOverlay in overlays.value.toList()) {
      overlays.remove(activeOverlay);
    }
  }
}
