import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/powerup_component.dart';
import 'package:moonlander/main.dart';
import 'package:moonlander/terrain_generator.dart';

/// Map rendering component.
class MapComponent extends Component with HasGameRef<MoonlanderGame> {
  /// Map rendering component.
  MapComponent({
    this.lengthOfMap = 100,
    this.mapSeed,
  });

  /// The seed used for terrain generation.
  final int? mapSeed;

  /// Length of the map in grid units.
  final double lengthOfMap;

  /// The workable grid sizes.
  static final grid = Vector2(40, 30);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    children.register<PowerupComponent>();
    // Size of a single item in the grid.
    final itemSize = gameRef.size.clone()..divide(MapComponent.grid);
    unawaited(
      addAll(
        TerrainGenerator(
          size: Vector2(lengthOfMap, grid.y / 3),
          amountOfLandingSpots: 10,
          amountOfPowerups: 5,
          maxPowerupHeight: (grid.y - 5).toInt(),
          seed: mapSeed,
        ).generate(itemSize, gameRef.size.clone()),
      ),
    );

    // Set the world bounds to the max size of the map.
    gameRef.camera.worldBounds = Rect.fromLTWH(
      0,
      0,
      lengthOfMap * itemSize.x,
      grid.y * itemSize.y,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawGrid(canvas);
  }

  ///Reset all powerups of the current map
  void resetPowerups() {
    children.query<PowerupComponent>().forEach((element) {
      element.used = false;
    });
  }

  /// If in debug mode draws the grid.
  void drawGrid(Canvas canvas) {
    if (!gameRef.debugMode) {
      return;
    }
    // Size of a single item in the grid.
    final itemSize = gameRef.size.clone()..divide(grid);

    for (var x = 0; x < lengthOfMap; x++) {
      for (var y = 0; y < grid.y; y++) {
        canvas.drawRect(
          Rect.fromLTWH(x * itemSize.x, y * itemSize.y, itemSize.x, itemSize.y),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.pink
            ..strokeWidth = .1,
        );
      }
    }
  }
}
