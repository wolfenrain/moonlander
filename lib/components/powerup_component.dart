import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:moonlander/components/rocket_component.dart';

///A power up that gets collected on contact
abstract class PowerupComponent extends SpriteComponent
    with HasGameRef, CollisionCallbacks {
  ///Create a power up at the given position
  PowerupComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  ///Roation in degree by second
  final double _roationBySecond = 90;

  bool _used = false;

  ///If true no and the power up will be hidden
  bool get used => _used;
  set used(bool value) {
    if (value != _used) {
      final effectController = EffectController(
        duration: 0.75,
      );
      if (value) {
        //The element was used, add fade effect
        add(OpacityEffect.fadeOut(effectController));
      } else {
        add(OpacityEffect.fadeIn(effectController));
      }
      _used = value;
    }
  }

  ///Get the name of the sprite to use
  String getPowerupSprite();

  ///What should happen if the player touches the element
  void onPlayerContact(RocketComponent player);

  @override
  Future<void>? onLoad() async {
    sprite = await gameRef.loadSprite(getPowerupSprite());
    anchor = Anchor.center;
    await add(CircleHitbox(radius: 0.9 * size.x / 2));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    angle += radians(_roationBySecond * dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_used == false) {
      if (other is RocketComponent) {
        onPlayerContact(other);
        used = true;
      }
    }
    super.onCollision(intersectionPoints, other);
  }
}
