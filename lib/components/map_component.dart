import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/main.dart';
import 'package:moonlander/terrain_generator.dart';

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

    final points = TerrainGenerator(
      size: Vector2(grid.x, grid.y / 3),
    ).generate();

    for (var i = 1; i < points.length; i++) {
      final startPos = convert(points[i - 1]);
      final endPos = convert(points[i]);

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
