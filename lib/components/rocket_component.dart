import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonlander/components/explosion_component.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/map_component.dart';
import 'package:moonlander/game_state.dart';

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

  final _animationSpeed = .1;
  var _animationTime = 0.0;
  final _velocity = Vector2.zero();
  final _gravity = Vector2(0, 1);
  var _collisionActive = false;

  final _fuelUsageBySecond = 10;

  double _fuel = 100;

  ///Acceleration factor of the rocket
  final speed = 5;

  ///Fuel remaning
  double get fuel => _fuel;

  ///Velocity of the rocket
  Vector2 get velocity => _velocity;

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

  final _rnd = Random();
  void _createEngineParticels() {
    final colorLerp = _rnd.nextDouble();
    final particelOffset = Vector2(size.x * 0.4, size.y * 0.8);
    gameRef.add(
      ParticleComponent(
        AcceleratedParticle(
          position: position.clone()..add(particelOffset),
          speed: Vector2(
            _rnd.nextDouble() * 200 - 100,
            -max(_rnd.nextDouble(), 0.1) * 100,
          ),
          child: CircleParticle(
            radius: 1.0,
            paint: Paint()
              ..color = Color.lerp(Colors.orange, Colors.red, colorLerp)!,
          ),
        ),
      ),
    );
  }

  void _updateVelocity(double dt) {
    //Get the direction of the vector2 and scale it with the speed and framerate
    if (!joystick.delta.isZero()) {
      final joyStickDelta = joystick.delta.clone();
      joyStickDelta.y = joyStickDelta.y.clamp(-1 * double.infinity, 0);
      _velocity.add(joyStickDelta.normalized() * (speed * dt));
      _fuel -= _fuelUsageBySecond * dt;
      if (_fuel < 0) {
        _loose();
      } else {
        _createEngineParticels();
      }
    }
    //Max speed is equal to two grid cells
    final maxSpeed = gameRef.size.clone()
      ..divide(MapComponent.grid)
      ..scale(2)
      ..divide(Vector2.all(speed.toDouble()));

    final gravityChange = _gravity.normalized() * (dt * 0.8);

    _velocity
      ..add(gravityChange)
      ..clamp(
        maxSpeed.scaled(-1),
        maxSpeed,
      );
  }

  @override
  void render(Canvas canvas) {
    ///If we lost we dont show the rocket anymore
    if (GameState.playState == PlayingState.lost) return;
    super.render(canvas);
    if (gameRef.debugMode) {
      debugTextPaint.render(canvas, 'Fuel:$fuel', Vector2(size.x, 0));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_collisionActive) return;
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

    final worldBounds = gameRef.camera.worldBounds!;
    final nextPosition = position + _velocity;

    // Check if the next position is within the world bounds on the X axis.
    // If it is we set the position to it, otherwise we set velocity to 0.
    if (worldBounds.left <= nextPosition.x &&
        nextPosition.x + size.x <= worldBounds.right) {
      position.x = nextPosition.x;
    } else {
      _velocity.x = 0;
    }

    // Check if the next position is within the world bounds on the y axis.
    // If it is we set the position to it, otherwise we set velocity to 0.
    if (nextPosition.y + size.y <= worldBounds.bottom) {
      position.y = nextPosition.y;
    }

    _animationTime += dt;
    if (_animationTime >= _animationSpeed) {
      _setAnimationState();
      _animationTime = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (_collisionActive) {
      return;
    }
    final hitBox = hitboxes.first;
    final leftHit = Rect.fromLTWH(
      hitBox.position.x,
      hitBox.position.y,
      hitBox.size.x * 0.5,
      hitBox.size.y * 0.7,
    );
    final rightHit = Rect.fromLTWH(
      hitBox.position.x + hitBox.size.x * 0.5,
      hitBox.position.y,
      hitBox.size.x * 0.5,
      hitBox.size.y * 0.7,
    );
    final bottomHit = Rect.fromLTWH(
      hitBox.position.x,
      hitBox.position.y + hitBox.size.y * 0.7,
      hitBox.size.x,
      hitBox.size.y * 0.7,
    );
    debugPrint("Left: " + leftHit.toString());
    debugPrint("Right: " + rightHit.toString());
    debugPrint("Bottom: " + bottomHit.toString());
    for (final point in intersectionPoints) {
      final hitRec = point.toPositionedRect(Vector2.all(1));
      debugPrint('Hit rect: ' + hitRec.toString());
      if (leftHit.intersect(hitRec).size.isEmpty == false) {
        debugPrint('Hit left');
      } else if (rightHit.intersect(hitRec).size.isEmpty == false) {
        debugPrint('Hit right');
      } else if (bottomHit.intersect(hitRec).size.isEmpty == false) {
        debugPrint('Hit bottom');
      }
    }
    if (other is LineComponent) {
      _loose();
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loose() {
    _velocity.scale(0); // Stop any movement
    _collisionActive = true;
    current = RocketState.idle;
    // For now you can only lose
    GameState.playState = PlayingState.lost;
    gameRef.add(
      ExplosionComponent(
        position.clone()
          ..add(
            Vector2(size.x / 2, 0),
          ),
        angle: -angle,
      ),
    );
  }

  /// Restart the rocket.
  void reset() {
    position = gameRef.size / 2;
    _collisionActive = false;
    _velocity.scale(0);
    current = RocketState.idle;
    angle = 0;
    _fuel = 100;
  }
}
