import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';

/// Temporay, rc17 will have this component
class ShapeComponent extends PositionComponent with Hitbox {
  final HitboxShape shape;
  Paint paint;

  ShapeComponent(
    this.shape, {
    Paint? paint,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  })  : paint = paint ?? BasicPalette.white.paint(),
        super(
          position: position,
          size: size,
          scale: scale,
          angle: angle ?? 0,
          anchor: anchor ?? Anchor.topLeft,
          priority: priority,
        ) {
    shape.isCanvasPrepared = true;
    addHitbox(shape);
  }

  @override
  void render(Canvas canvas) {
    shape.render(canvas, paint);
  }
}

/// Temporay, rc17 will have this component
class CircleComponent extends ShapeComponent {
  CircleComponent({
    required double radius,
    Paint? paint,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          HitboxCircle(),
          paint: paint,
          position: position,
          size: Vector2.all(radius * 2),
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        );
}
