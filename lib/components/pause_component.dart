import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:moonlander/main.dart';

/// A simple sprite component that pauses the game when tapped.
class PauseComponent extends SpriteComponent
    with Tappable, HasGameRef<MoonlanderGame> {
  /// Position to show the button.
  PauseComponent({
    required Vector2 position,
    required Sprite sprite,
  }) : super(position: position, size: Vector2(50, 25), sprite: sprite);

  @override
  bool get isHud => true;

  @override
  bool onTapDown(TapDownInfo info) {
    if (gameRef.overlays.isActive('pause')) {
      gameRef.overlays.remove('pause');
    } else {
      gameRef.overlays.add('pause');
    }

    return super.onTapDown(info);
  }
}
