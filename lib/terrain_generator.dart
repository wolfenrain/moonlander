import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/powerup_fuel_component.dart';

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
    required this.amountOfLandingSpots,
    required this.amountOfPowerups,
    required this.maxPowerupHeight,
  }) {
    _random = Random(seed);
    assert(size.y < maxPowerupHeight, 'MaxPowerupHeight must be above size.y');
  }

  /// Determines the max step.
  final double maxStep;

  /// The amount a step can change.
  final double stepChange;

  /// Amount of landing spots the terrain will generate.
  final int amountOfLandingSpots;

  ///Amount of powerups
  final int amountOfPowerups;

  ///Maximum powerup height
  final int maxPowerupHeight;

  /// Size of the terrain.
  final Vector2 size;

  /// Seed used for the [Random]ness.
  final int? seed;

  late final Random _random;

  /// Generate list of points that represent the terrain.
  List<PositionComponent> generate(
    Vector2 itemSize,
    Vector2 gamzeSize,
  ) {
    // The initial starting values.
    var height = _random.nextDouble() * size.y;
    //Keep the slope in the range of -maxStep to maxStep
    var slope = lerpDouble(-maxStep, maxStep, _random.nextDouble())!;

    final points = <Vector2>[];

    final landingSpots = <int>[];
    while (landingSpots.length < amountOfLandingSpots) {
      final index = _random.nextInt(size.x.toInt());
      if (!landingSpots.contains(index)) {
        landingSpots.add(index);
      }
    }
    final powerUps = <PositionComponent>[];
    while (powerUps.length < amountOfPowerups) {
      final x = _random.nextInt(size.x.toInt());
      if (!powerUps
          .any((element) => element.position.x == x.toDouble() * itemSize.x)) {
        powerUps.add(
          PowerupFuelComponent(
            position: Vector2(
              x.toDouble() * itemSize.x,
              gamzeSize.y -
                  (_nextBetween(size.y.toInt(), maxPowerupHeight) * itemSize.y),
            ),
          ),
        );
      }
    }

    for (var x = 0.0; x <= size.x; x++) {
      if (landingSpots.contains(x)) {
        points.add(Vector2(x, height));
        continue;
      }

      // Update the height by adding the previous slope.
      height += slope;

      // Update the slope by a random step change.
      slope += lerpDouble(-stepChange, stepChange, _random.nextDouble())!;

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

    return [
      for (var i = 1; i < points.length; i++)
        LineComponent(
          points[i - 1],
          points[i],
          isGoal: landingSpots.contains(i),
        ),
      ...powerUps
    ];
  }

  int _nextBetween(int min, int max) => min + _random.nextInt(max - min);
}
