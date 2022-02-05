import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/position_body_component.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/explosion_component.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/map_component.dart';
import 'package:moonlander/components/particel_generator.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/main.dart';

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

/// Component that keeps track of our rocket body.
class RocketComponent extends PositionBodyComponent<MoonlanderGame> {
  /// Create a new Rocket component at the given [position].
  RocketComponent({
    required Vector2 position,
    required Vector2 size,
    required this.joystick,
  }) : super(
          positionComponent: _RocketComponent(position: position, size: size),
          size: size,
        );

  /// Joystick that controls this rocket.
  final JoystickComponent joystick;

  var _heading = RocketHeading.idle;
  final _engineSoundCoolDown = 0.2;
  var _engineSoundCounter = 0.2;
  final _animationSpeed = .1;
  var _animationTime = 0.0;
  var _collisionActive = false;

  final _fuelUsageBySecond = 10;

  late final Vector2 _particelOffset;
  double _fuel = 100;

  ///Acceleration factor of the rocket
  final double speed = 0.1;

  /// Wrapper around the rocket state for rendering.
  RocketState? get current => (positionComponent! as _RocketComponent).current;
  set current(RocketState? state) {
    (positionComponent! as _RocketComponent).current = state;
  }

  /// Wrapper around the position of the rocket.
  Vector2 get position => (positionComponent! as _RocketComponent).position;
  set position(Vector2 position) {
    (positionComponent! as _RocketComponent).position = position;
  }

  ///Fuel remaning
  double get fuel => _fuel;
  set fuel(double value) {
    _fuel = min(value, 100);
  }

  double _flyingTime = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _particelOffset = Vector2(0, size.y * 0.2);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 2;
    final fixtureDef = FixtureDef(shape)
      ..userData = this // To be able to determine object in collision
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.2;

    final bodyDef = BodyDef()
      ..position = position.clone()
      ..type = BodyType.dynamic;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  bool get _isJoyStickIdle => joystick.direction == JoystickDirection.idle;

  // Place holder, later we need to animate based on speed in a given direction.
  void _setAnimationState() {
    switch (_heading) {
      case RocketHeading.idle:
        if (current != RocketState.idle) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
            body.angularVelocity = radians(-7.5);
          } else if (current == RocketState.farRight) {
            current = RocketState.right;
            body.angularVelocity = radians(7.5);
          } else {
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
            body.angularVelocity = radians(0);
            // angle = radians(0);
          }
        } else {
          current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
        }
        break;
      case RocketHeading.left:
        if (current != RocketState.farLeft) {
          if (current == RocketState.farRight) {
            current = RocketState.right;
            // angle = radians(7.5);
          } else if (current == RocketState.right) {
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
            // angle = radians(0);
          } else if (current == RocketState.idle) {
            current = RocketState.left;
            // angle = radians(-7.5);
          } else {
            current = RocketState.farLeft;
            // angle = radians(-15);
          }
        }
        break;
      case RocketHeading.right:
        if (current != RocketState.farRight) {
          if (current == RocketState.farLeft) {
            current = RocketState.left;
            // angle = radians(-7.5);
          } else if (current == RocketState.left) {
            current = _isJoyStickIdle ? RocketState.idle : RocketState.upDown;
            // angle = radians(0);
          } else if (current == RocketState.idle) {
            current = RocketState.right;
            // angle = radians(7.5);
          } else {
            current = RocketState.farRight;
            // angle = radians(15);
          }
        }
        break;
    }
  }

  void _createEngineParticels() {
    gameRef.add(
      ParticelGenerator.createEngineParticle(
        position: position.clone()..add(_particelOffset),
      ),
    );
  }

  void _updateVelocity(double dt) {
    //Get the direction of the vector2 and scale it with the speed and framerate
    _flyingTime += dt;
    if (!joystick.delta.isZero()) {
      final joyStickDelta = joystick.delta.clone();
      joyStickDelta.y = joyStickDelta.y.clamp(-1 * double.infinity, 0) * -1;
      body.applyLinearImpulse(joyStickDelta * speed);
      _fuel -= _fuelUsageBySecond * dt;
      if (_fuel < 0) {
        _loose();
      } else {
        _createEngineParticels();
        if (_engineSoundCounter >= _engineSoundCoolDown) {
          gameRef.audioPlayer.playEngine();
          _engineSoundCounter = 0;
        } else {
          _engineSoundCounter += dt;
        }
      }
    }
    //Max speed is equal to two grid cells
    //TODO cap this before we reache the cap of forge
  }

  @override
  // TODO: implement debugMode
  bool get debugMode => true;

  @override
  void renderDebugMode(Canvas canvas) {
    // TODO: implement renderDebugMode
    super.renderDebugMode(canvas);
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

/*    final worldBounds = gameRef.camera.worldBounds!;
    final nextPosition = position + body.linearVelocity;

    // Check if the next position is within the world bounds on the X axis.
    // If it is we set the position to it, otherwise we set velocity to 0.
    // TODO(wolfen): I think Forge2D can handle this?
    if (worldBounds.left <= nextPosition.x &&
        nextPosition.x + size.x <= worldBounds.right) {
      position.x = nextPosition.x;
    } else {
      body.linearVelocity.x = 0;
    }

    // Check if the next position is within the world bounds on the y axis.
    // If it is we set the position to it, otherwise we set velocity to 0.
    if (nextPosition.y + size.y <= worldBounds.bottom) {
      position.y = nextPosition.y;
    }*/

    _animationTime += dt;
    if (_animationTime >= _animationSpeed) {
      _setAnimationState();
      _animationTime = 0;
    }
  }

  void _win(LineComponent landingSpot) {
    _calculateScore(landingSpot);
    body.linearVelocity.scale(0);
    _collisionActive = true;
    current = RocketState.idle;
    GameState.playState = PlayingState.won;
    gameRef.overlays.add('pause');
    _updateScores();
  }

  void _updateScores() {
    if (GameState.currentLevel != null) {
      GameState.database
          .updateScoreForLevel(GameState.lastScore, GameState.currentLevel!.id);
    }
    GameState.database
        .createNewHighScoreEntry(GameState.seed, GameState.lastScore);
  }

  void _calculateScore(LineComponent landingSpot) {
    final landingSpotScore = landingSpot.score;

    GameState.lastScore =
        (fuel * (body.linearVelocity.y.abs() * speed) * landingSpotScore) ~/
            _flyingTime;
  }

  void _loose() {
    body.linearVelocity.scale(0); // Stop any movement
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
    body.setTransform(Vector2(gameRef.size.x / 2, -gameRef.size.y / 2), 0);
    _collisionActive = false;
    body.linearVelocity.scale(0);
    current = RocketState.idle;
    _fuel = 100;
    _flyingTime = 0;
  }
}

/// A component that renders the Rocket with the different states.
class _RocketComponent extends SpriteAnimationGroupComponent<RocketState>
    with HasGameRef<MoonlanderGame> {
  /// Create a new Rocket component at the given [position].
  _RocketComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, animations: {});

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
  }

  @override
  void render(Canvas canvas) {
    ///If we lost we dont show the rocket anymore
    if (GameState.playState == PlayingState.lost) return;
    // super.render(canvas);
  }
}
