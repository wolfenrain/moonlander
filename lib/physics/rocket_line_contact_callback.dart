import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/rocket_component.dart';

/// Handles collision between rocket and line.
class RocketLineContactCallback
    extends ContactCallback<RocketComponent, LineComponent> {
  @override
  void begin(RocketComponent a, LineComponent b, Contact contact) {}

  @override
  void end(RocketComponent a, LineComponent b, Contact contact) {
    var crashed = b.isGoal;

    if (crashed) {
      a.loose();
    } else {
      a.win(b);
    }
  }
}
