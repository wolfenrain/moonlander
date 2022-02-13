// ignore_for_file: cascade_invocations

import 'package:canvas_test/canvas_test.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/main.dart';

final fixedGameSize = Vector2(
  800,
  600,
);

final moonLanderGameTester = FlameTester(
  MoonlanderGame.new,
  gameSize: fixedGameSize,
);

//TODO(CM): Adjust the test code to match the Forge2D line component

void main() {
  group('canvas tests', () {
    test('draw LineComponent normal line', () {
      final canvas = MockCanvas();
      final startPos = Vector2.zero();
      final endPos = Vector2.all(10);
      final lineComponent = LineComponent(startPos, endPos);
      lineComponent.render(canvas);
      expect(
        canvas,
        MockCanvas()
          ..drawLine(
            Offset.zero,
            Offset(1, 0), //Needs to be changed to the actual line length
            linePaint,
          ),
      );
    });

    test('draw LineComponent goal line', () {
      final canvas = MockCanvas();
      final startPos = Vector2.zero();
      final endPos = Vector2.all(10);
      final lineComponent = LineComponent(
        startPos,
        endPos,
        isGoal: true,
      );
      lineComponent.render(canvas);

      expect(
        canvas,
        createGoalLineMockCanvas(lineComponent),
      );
    });
  });
}

MockCanvas createGoalLineMockCanvas(LineComponent lineComponent) {
  final textPainter = TextPaint(
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[700],
    ),
  );
  final canvas = MockCanvas()
    ..drawLine(
      Offset.zero,
      Offset(1, 0),
      goalPaint,
    )
    ..save()
    ..rotate(-lineComponent.angle);
  const text = '+0';

  textPainter.render(
    canvas,
    text,
    Vector2(
      textPainter.measureTextWidth(text),
      -textPainter.measureTextHeight(text) - 5,
    ),
    anchor: Anchor.topCenter,
  );

  canvas.restore();
  return canvas;
}
