import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:moonlander/components/powerup_component.dart';

///Basic representation of the powerup in the phyiscs wolrd
class BasicPhysicsPowerup extends BodyComponent {
  ///Position and size of the power up
  BasicPhysicsPowerup(this._position, this._size, this.powerupComponent);

  final Vector2 _position;
  final Vector2 _size;

  ///Triggered by the ContactCallback on collision
  final PowerupComponent powerupComponent;

  @override
  Body createBody() {
    debugMode = false;
    final shape = CircleShape()..radius = _size.x / 2;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0
      ..density = 0
      ..friction = 0
      ..isSensor = true;

    final physicsPosition = _position..multiply(Vector2(1, -1));
    final bodyDef = BodyDef()
      ..position = physicsPosition
      ..type = BodyType.kinematic
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
