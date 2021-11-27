import 'dart:math';

import 'package:flame/extensions.dart';

/// Terrain generator.
///
/// Based on: https://gamedev.stackexchange.com/a/93531
class TerrainGenerator {
  /// Terrain generator.
  TerrainGenerator({
    this.maxStep = 2.5,
    this.stepChange = 1.0,
    required this.size,
    this.seed,
  });

  /// Determines the max step.
  final double maxStep;

  /// The amount a step can change.
  final double stepChange;

  /// Size of the terrain.
  final Vector2 size;

  /// Seed used for the [Random]ness.
  final int? seed;

  /// Generate list of points that represent the terrain.
  List<Vector2> generate() {
    final random = Random(seed);

    // The initial starting values.
    var height = random.nextDouble() * size.y;
    //Keep the slope in the range of -maxStep to maxStep
    var slope = (random.nextDouble() * maxStep) * 2 - maxStep;

    final points = <Vector2>[];
    for (var x = 0.0; x <= size.x; x++) {
      // Update the height by adding the previous slope.
      height += slope;

      // Update the slope by a random step change.
      slope += (random.nextDouble() * stepChange) * 2 - stepChange;

      // Clamp the slope to the max step.
      slope = slope.clamp(-maxStep, maxStep);

      // If the height is bigger than the size height, clip it and
      // reverse the slope.
      if (height > size.y) {
        height = size.y;
        slope *= -1;
      }

      // If the height is smaller than zero, clip it and reverse the slope.
      if (height < 0) {
        height = 0;
        slope *= -1;
      }

      points.add(Vector2(x, height));
    }
    return points;
  }
}
