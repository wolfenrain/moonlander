import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:moonlander/components/powerup_physics_base.dart';
import 'package:moonlander/components/rocket_component.dart';

///Handles collision between rocket and powerup
class RocketPowerUpContactCallback
    extends ContactCallback<RocketComponent, BasicPhysicsPowerup> {
  @override
  void begin(RocketComponent a, BasicPhysicsPowerup b, Contact contact) {}

  @override
  void end(RocketComponent a, BasicPhysicsPowerup b, Contact contact) {
    if (!b.powerupComponent.used) {
      b.powerupComponent.onPlayerContact(a);
      b.powerupComponent.used = true;
    }
  }
}
