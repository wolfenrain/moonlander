import 'dart:math';

import 'package:flame/game.dart';
import 'package:moonlander/components/powerup_component.dart';
import 'package:moonlander/components/rocket_component.dart';

///A power up that adds fuel to the rocket on touch
class PowerupFuelComponent extends PowerupComponent {
  ///Create a new fuel powerup
  PowerupFuelComponent({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(32),
        );

  @override
  String getPowerupSprite() {
    return 'energyball_fuel.png';
  }

  @override
  void onPlayerContact(RocketComponent player) {
    player.fuel = min<double>(100, player.fuel + 25);
  }
}
