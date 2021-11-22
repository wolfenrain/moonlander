import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/main.dart';

/// Map rendering component.
class MapComponent extends Component with HasGameRef<MoonlanderGame> {
  /// The workable grid sizes.
  static final grid = Vector2(40, 30);

  /// Size of a single item in the [grid].
  Vector2 get size => gameRef.size.clone()..divide(grid);

  /// Convert [point] to a position on the grid.
  Vector2 convert(Vector2 point) {
    return Vector2(
      size.x * point.x,
      gameRef.size.y - size.y * point.y,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final lines = [
      Vector2(0, 0),
      Vector2(1, 1),
      Vector2(2, 1),
      Vector2(3, 2),
      Vector2(4, 2),
    ];

    for (var i = 1; i < lines.length; i++) {
      final startPos = convert(lines[i - 1]);
      final endPos = convert(lines[i]);

      await add(LineComponent(startPos, endPos));
    }
  }

  @override
  void preRender(Canvas canvas) {
    if (!kDebugMode) {
      return;
    }

    for (var x = 0; x < grid.x; x++) {
      for (var y = 0; y < grid.y; y++) {
        canvas.drawRect(
          Rect.fromLTWH(x * size.x, y * size.y, size.x, size.y),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.pink
            ..strokeWidth = .1,
        );
      }
    }
  }
}
