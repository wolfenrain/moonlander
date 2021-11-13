import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Describes the render state of the [RocketComponent].
enum RocketState {
  /// Rocket is idle.
  idle,

  /// Rocket is slightly to the left.
  left,

  /// Rocket is slightly to the right.
  right,

  /// Rocket is to the far left.
  farLeft,

  /// Rocket is to the far right.
  farRight,
}

/// Describe the heading of the [RocketComponent].
enum RocketHeading {
  /// Rocket is heading to the left.
  left,

  /// Rocket is heading to the right.
  right,

  /// Rocket is idle.
  idle,
}

/// A component that renders the Rocket with the different states.
class RocketComponent extends SpriteAnimationGroupComponent<RocketState>
    with Hitbox, Collidable, KeyboardHandler, HasGameRef {
  /// Create a new Rocket component at the given [position].
  RocketComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, animations: {});

  var _heading = RocketHeading.idle;
  final _speed = 10;
  final _animationSpeed = .1;
  var _animationTime = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //Load all sprites and create the animation map
    const stepTime = .3;
    final textureSize = Vector2(16, 24);
    const frameCount = 2;
    final idle = await gameRef.loadSpriteAnimation(
      'ship_animation_idle.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final left = await gameRef.loadSpriteAnimation(
      'ship_animation_left.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final right = await gameRef.loadSpriteAnimation(
      'ship_animation_right.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final farRight = await gameRef.loadSpriteAnimation(
      'ship_animation_far_right.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    final farLeft = await gameRef.loadSpriteAnimation(
      'ship_animation_far_left.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    animations = {
      RocketState.idle: idle,
      RocketState.left: left,
      RocketState.right: right,
      RocketState.farLeft: farLeft,
      RocketState.farRight: farRight
    };
    current = RocketState.idle;
    addHitbox(HitboxRectangle());
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        _heading = RocketHeading.left;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        _heading = RocketHeading.right;
      } else {
        _heading = RocketHeading.idle;
      }
    }
    return true;
  }

  // Place holder, later we need to animate based on speed in a given direction.
  void _setAnimationState() {
    switch (_heading) {
      case RocketHeading.idle:
        if (current != RocketState.idle) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
          } else if (current == RocketState.farRight) {
            current = RocketState.right;
          } else {
            current = RocketState.idle;
          }
        }
        break;
      case RocketHeading.left:
        if (current != RocketState.farLeft) {
          if (current == RocketState.farRight) {
            current = RocketState.right;
          } else if (current == RocketState.right) {
            current = RocketState.idle;
          } else if (current == RocketState.idle) {
            current = RocketState.left;
          } else {
            current = RocketState.farLeft;
          }
        }
        break;
      case RocketHeading.right:
        if (current != RocketState.farRight) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
          } else if (current == RocketState.left) {
            current = RocketState.idle;
          } else if (current == RocketState.idle) {
            current = RocketState.right;
          } else {
            current = RocketState.farRight;
          }
        }
        break;
    }
  }

  @override
  void update(double dt) {
    position.y += _speed * dt;
    _animationTime += dt;
    if (_animationTime >= _animationSpeed) {
      _setAnimationState();
      _animationTime = 0;
    }

    super.update(dt);
  }
}
