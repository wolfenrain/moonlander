import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';

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
    with Hitbox, Collidable, HasGameRef {
  /// Create a new Rocket component at the given [position].
  RocketComponent({
    required Vector2 position,
    required Vector2 size,
    required this.joystick,
  }) : super(position: position, size: size, animations: {});

  /// Joystick that controls this rocket.
  final JoystickComponent joystick;

  var _heading = RocketHeading.idle;
  final _speed = 7;
  final _animationSpeed = .1;
  var _animationTime = 0.0;
  final _velocity = Vector2.zero();
  final _gravity = Vector2(0, 5);

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

  // Place holder, later we need to animate based on speed in a given direction.
  void _setAnimationState() {
    switch (_heading) {
      case RocketHeading.idle:
        if (current != RocketState.idle) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
            angle = radians(-7.5);
          } else if (current == RocketState.farRight) {
            current = RocketState.right;
            angle = radians(7.5);
          } else {
            current = RocketState.idle;
            angle = radians(0);
          }
        }
        break;
      case RocketHeading.left:
        if (current != RocketState.farLeft) {
          if (current == RocketState.farRight) {
            current = RocketState.right;
            angle = radians(7.5);
          } else if (current == RocketState.right) {
            current = RocketState.idle;
            angle = radians(0);
          } else if (current == RocketState.idle) {
            current = RocketState.left;
            angle = radians(-7.5);
          } else {
            current = RocketState.farLeft;
            angle = radians(-15);
          }
        }
        break;
      case RocketHeading.right:
        if (current != RocketState.farRight) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
            angle = radians(-7.5);
          } else if (current == RocketState.left) {
            current = RocketState.idle;
            angle = radians(0);
          } else if (current == RocketState.idle) {
            current = RocketState.right;
            angle = radians(7.5);
          } else {
            current = RocketState.farRight;
            angle = radians(15);
          }
        }
        break;
    }
  }

  void _updateVelocity(double dt) {
    //Get the direction of the vector2 and scale it with the speed and framerate
    if (!joystick.delta.isZero()) {
      _velocity.add(joystick.delta.normalized() * (_speed * dt));
    }
    _velocity
      ..add(_gravity.normalized() * dt)
      ..clampScalar(-10, 10);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    debugTextPaint.render(canvas, 'V:$_velocity', Vector2(size.x, 0));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick.direction == JoystickDirection.left &&
        _heading != RocketHeading.left) {
      _heading = RocketHeading.left;

      _animationTime = 0;
    } else if (joystick.direction == JoystickDirection.right &&
        _heading != RocketHeading.right) {
      _heading = RocketHeading.right;
      _animationTime = 0;
    } else if (joystick.direction == JoystickDirection.idle &&
        _heading != RocketHeading.idle) {
      _heading = RocketHeading.idle;
      _animationTime = 0;
    }
    _updateVelocity(dt);
    position.add(_velocity);
    _animationTime += dt;
    if (_animationTime >= _animationSpeed) {
      _setAnimationState();
      _animationTime = 0;
    }
  }
}
