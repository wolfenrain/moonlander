import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/rocket_component.dart';
import 'package:moonlander/game_state.dart';

/// Handles collision between rocket and line.
class RocketLineContactCallback
    extends ContactCallback<RocketComponent, LineComponent> {
  double _totalImpactImpulse = 0;
  int _contactCounter = 1;

  @override
  void begin(RocketComponent a, LineComponent b, Contact contact) {
    _contactCounter = 1;
    _totalImpactImpulse = 0;
  }

  @override
  void postSolve(
    RocketComponent a,
    LineComponent b,
    Contact contact,
    ContactImpulse impulse,
  ) {
    if (contact.isTouching()) {
      // The impact impules of the two bodies.
      _totalImpactImpulse += impulse.normalImpulses[0].abs();
      _contactCounter++;
    }
  }

  @override
  void end(RocketComponent a, LineComponent b, Contact contact) {
    if (GameState.playState == PlayingState.playing) {
      final avgImpactImpulse = _totalImpactImpulse / _contactCounter;
      final crashed = avgImpactImpulse > 15;
      debugPrint('impact impulse total: $avgImpactImpulse');
      if (!crashed && b.isGoal) {
        a.win(b, avgImpactImpulse);
      } else if (crashed) {
        a.loose();
      }
    } else {
      debugPrint('Contact while not playing');
    }
  }
}
