import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/map_component.dart';

/// Paint object for when it should be a normal line.
final linePaint = Paint()..color = Colors.white;

/// Paint object for when it should be a goal line.
final goalPaint = Paint();

/// A single line component that is collidable. Part of a [MapComponent].
class LineComponent extends PositionComponent with Hitbox, Collidable {
  /// Construct the line with given positions.
  LineComponent(
    Vector2 startPos,
    Vector2 endPos, {
    this.isGoal = false,
  }) : super(
          position: startPos,
          angle: atan2(endPos.y - startPos.y, endPos.x - startPos.x),
          size: Vector2(endPos.distanceTo(startPos), 1),
        );

  /// Indicates if this line is the end goal or not.
  final bool isGoal;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    addHitbox(HitboxRectangle());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(
      Offset.zero,
      Offset(size.x, 1),
      isGoal ? goalPaint : linePaint,
    );
  }
}
