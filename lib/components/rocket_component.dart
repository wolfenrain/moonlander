import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';
import 'package:moonlander/components/line_component.dart';

/// Describes the render state of the [RocketComponent].
enum RocketState {
  /// Rocket is idle.
  idle,

  ///Rocket thrust up or down.
  upDown,

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
    with HasHitboxes, Collidable, HasGameRef {
  /// Create a new Rocket component at the given [position].
  RocketComponent({
    required Vector2 position,
    required Vector2 size,
    required this.joystick,
  }) : super(position: position, size: size, animations: {});

  /// Joystick that controls this rocket.
  final JoystickComponent joystick;

  var _heading = RocketHeading.idle;
  final _speed = 5;
  final _animationSpeed = .1;
  var _animationTime = 0.0;
  final _velocity = Vector2.zero();
  final _gravity = Vector2(0, 1);
  var _collision = false;

  final _fuelUsageBySecond = 5;

  double _fuel = 100;

  ///Fuel remaning
  double get fuel => _fuel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    //Rocket sprite sheet with animation groups
    const stepTime = .3;
    const frameCount = 2;
    final image = await gameRef.images.load('ship_spritesheet.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: frameCount,
      rows: RocketState.values.length,
    );

    final idle = sheet.createAnimation(row: 0, stepTime: stepTime);
    final upDown = sheet.createAnimation(row: 1, stepTime: stepTime);
    final left = sheet.createAnimation(row: 2, stepTime: stepTime);
    final right = sheet.createAnimation(row: 3, stepTime: stepTime);
    final farRight = sheet.createAnimation(row: 4, stepTime: stepTime);
    final farLeft = sheet.createAnimation(row: 5, stepTime: stepTime);
    animations = {
      RocketState.idle: idle,
      RocketState.upDown: upDown,
      RocketState.left: left,
      RocketState.right: right,
      RocketState.farLeft: farLeft,
      RocketState.farRight: farRight
    };
    current = RocketState.idle;
    addHitbox(HitboxRectangle(relation: Vector2(1, 0.55)));
  }

  bool get _isJoyStickIdle => joystick.direction == JoystickDirection.idle;

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
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
            angle = radians(0);
          }
        } else {
          current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
        }
        break;
      case RocketHeading.left:
        if (current != RocketState.farLeft) {
          if (current == RocketState.farRight) {
            current = RocketState.right;
            angle = radians(7.5);
          } else if (current == RocketState.right) {
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
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
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
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
      final joyStickDelta = joystick.delta.clone();
      joyStickDelta.y = joyStickDelta.y.clamp(-1 * double.infinity, 0);
      _velocity.add(joyStickDelta.normalized() * (_speed * dt));
      _fuel -= _fuelUsageBySecond * dt;
    }
    final gravityChange = _gravity.normalized() * (dt * 0.6);
    _velocity
      ..add(gravityChange)
      ..clamp(
        Vector2(-7, -4),
        Vector2(7, 4),
      ); // TODO(wolfen): align this to the device size?
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef.debugMode) {
      debugTextPaint.render(canvas, 'Fuel:$fuel', Vector2(size.x, 0));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collision) return;
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is LineComponent) {
      _velocity.scale(0); //Stop any movement
      _collision = true;
    }
    super.onCollision(intersectionPoints, other);
  }
}
