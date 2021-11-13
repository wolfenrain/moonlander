import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';

/// HudButtonComponent with one state and the ontap
class PauseComponent extends HudButtonComponent {
  ///Sprite and position of our button
  PauseComponent({
    required EdgeInsets margin,
    required Sprite sprite,
    required VoidCallback onPressed,
    Sprite? spritePressed,
  }) : super(
          button: SpriteComponent(
            position: Vector2.zero(),
            sprite: sprite,
            size: Vector2(50, 25),
          ),
          buttonDown: SpriteComponent(
            position: Vector2.zero(),
            sprite: spritePressed,
            size: Vector2(50, 25),
          ),
          margin: margin,
          onPressed: onPressed,
        );
}
