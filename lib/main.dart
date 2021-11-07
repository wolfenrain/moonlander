import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    with HasCollidables, HasTappableComponents, HasKeyboardHandlerComponents {
  /// Depending on the active overlay state we turn of the engine or not.
  void onOverlayChanged() {
    if (overlays.isActive('pause')) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

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
    final pausButton = await Sprite.load('PauseButton.png');
    const stepTime = .3;
    final textureSize = Vector2(16, 24);
    const frameCount = 2;
    final idle = await loadSpriteAnimation(
      'ship_animation_idle.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final left = await loadSpriteAnimation(
      'ship_animation_left.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final right = await loadSpriteAnimation(
      'ship_animation_right.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final farRight = await loadSpriteAnimation(
      'ship_animation_far_right.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final farLeft = await loadSpriteAnimation(
      'ship_animation_far_left.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final rocketAnimation = {
      RocketState.idle: idle,
      RocketState.left: left,
      RocketState.right: right,
      RocketState.farLeft: farLeft,
      RocketState.farRight: farRight
    };

    unawaited(
      add(
        RocketComponent(
          position: size / 2,
          size: Vector2(32, 48),
          animation: rocketAnimation,
        ),
      ),
    );
    unawaited(add(PauseComponent(position: Vector2(0, 0), sprite: pausButton)));
    //Only in debug mode, add 3s wait to simulate loading
    /*if (kDebugMode) {
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    */
    overlays.addListener(onOverlayChanged);

    return super.onLoad();
  }
}
