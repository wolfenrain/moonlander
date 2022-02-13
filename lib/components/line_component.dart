import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/map_component.dart';

/// Paint object for when it should be a normal line.
final linePaint = Paint()..color = Colors.white;

/// Paint object for when it should be a goal line.
final goalPaint = Paint()..color = Colors.lightBlue;

/// A single line component that is collidable. Part of a [MapComponent].
class LineComponent extends BodyComponent {
  /// Construct the line with given positions.
  LineComponent(
    this.startPos,
    this.endPos, {
    this.isGoal = false,
  });

  @override
  Body createBody() {
    debugMode = false; //prevent debug drawing
    final startPosition = convert(startPos);
    final endPosition = convert(endPos);

    final distance = endPosition.distanceTo(startPosition) / 2;

    final shape = PolygonShape()
      ..setAsBox(
        distance,
        .2,
        Vector2(distance, .2),
        0,
      );

    final fixtureDef = FixtureDef(shape);

    final bodyDef = BodyDef()
      ..position = startPosition
      ..type = BodyType.static
      ..angle = atan2(
        endPosition.y - startPosition.y,
        endPosition.x - startPosition.x,
      )
      ..userData = this;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  final _textPaint = TextPaint(
    style: TextStyle(
      fontSize: 2,
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
      -gameRef.size.y + (itemSize.y * point.y),
    );
  }

  final Matrix4 _flipYTransform = Matrix4.identity()..scale(1.0, -1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint = isGoal ? goalPaint : paint;

    // Register a query of its siblings for performance reasons.
    parent?.children.register<LineComponent>();
    parent?.children.query<LineComponent>();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderDebugMode(canvas);
    if (isGoal) {
      canvas
        ..save()
        ..rotate(-angle)
        ..transform(_flipYTransform.storage);
      _textPaint.render(
        canvas,
        '+$score',
        Vector2(
          _textPaint.measureTextWidth('+$score'),
          -_textPaint.measureTextHeight('+$score') - 1,
        ),
        anchor: Anchor.topCenter,
      );
      canvas.restore();
    }
  }
}
