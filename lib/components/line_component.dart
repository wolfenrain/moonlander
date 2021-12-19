import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/map_component.dart';
import 'package:moonlander/main.dart';

/// Paint object for when it should be a normal line.
final linePaint = Paint()..color = Colors.white;

/// Paint object for when it should be a goal line.
final goalPaint = Paint()..color = Colors.lightBlue;

/// A single line component that is collidable. Part of a [MapComponent].
class LineComponent extends PositionComponent
    with HasHitboxes, Collidable, HasGameRef<MoonlanderGame> {
  /// Construct the line with given positions.
  LineComponent(
    this.startPos,
    this.endPos, {
    this.isGoal = false,
  });

  final _textPaint = TextPaint(
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[700],
      fontFamily: 'AldotheApache',
    ),
  );

  /// The score of this line.
  int get score {
    final siblings = parent?.children.query<LineComponent>();
    if (siblings == null) {
      return 0;
    }
    const baseValue = 1;
    final index = siblings.indexOf(this);
    var angleValue = 1.0;

    if (index >= 0) {
      final next = siblings[index + 1];
      angleValue += ((angle - next.angle).abs() * radians2Degrees) / 180;
    }
    if (index <= siblings.length - 1) {
      final prev = siblings[index - 1];
      angleValue += ((prev.angle - angle).abs() * radians2Degrees) / 180;
    }

    return (baseValue * index * angleValue).toInt();
  }

  /// Indicates if this line is the end goal or not.
  final bool isGoal;

  /// Starting position on the grid for this line.
  final Vector2 startPos;

  /// End position on the grid for this line.
  final Vector2 endPos;

  /// Convert [point] to a position on the grid.
  Vector2 convert(Vector2 point) {
    // Size of a single item in the grid.
    final itemSize = gameRef.size.clone()..divide(MapComponent.grid);

    return Vector2(
      itemSize.x * point.x,
      gameRef.size.y - itemSize.y * point.y,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Ensures that lines wont trigger collisions with each other.
    collidableType = CollidableType.passive;

    // Register a query of its siblings for performance reasons.
    parent?.children.register<LineComponent>();
    parent?.children.query<LineComponent>();

    addHitbox(HitboxRectangle());
  }

  @override
  void onGameResize(Vector2 gameSize) {
    final startPosition = convert(startPos);
    final endPosition = convert(endPos);
    position = startPosition;
    angle = atan2(
      endPosition.y - startPosition.y,
      endPosition.x - startPosition.x,
    );
    size = Vector2(endPosition.distanceTo(startPosition), 1);

    super.onGameResize(gameSize);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawLine(
      Offset.zero,
      size.toOffset(),
      isGoal ? goalPaint : linePaint,
    );

    if (isGoal) {
      canvas
        ..save()
        ..rotate(-angle);
      _textPaint.render(
        canvas,
        '+$score',
        Vector2(
          _textPaint.measureTextWidth('+$score'),
          -_textPaint.measureTextHeight('+$score') - 5,
        ),
        anchor: Anchor.topCenter,
      );
      canvas.restore();
    }
  }
}
