// ignore_for_file: cascade_invocations

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonlander/components/line_component.dart';
import 'package:moonlander/components/powerup_component.dart';
import 'package:moonlander/main.dart';
import 'package:moonlander/terrain_generator.dart';

final fixedGameSize = Vector2(
  800,
  600,
);

final moonLanderGameTester = FlameTester(
  MoonlanderGame.new,
  gameSize: fixedGameSize,
);

void main() {
  group('terrain generator tests', () {
    var gameSize = Vector2(30, 20);
    var amountOfPowerUps = 10;
    var amountOfLandingSpots = 10;
    var maxPowerupHeight = 40;

    //Back to default
    tearDown(() {
      gameSize = Vector2(30, 20);
      amountOfPowerUps = 10;
      amountOfLandingSpots = 10;
      maxPowerupHeight = 40;
    });

    test('ensure terrain is created', () {
      final terrainGenerator = createTestGenerator(
        amountOfLandingSpots,
        amountOfPowerUps,
        maxPowerupHeight,
        gameSize,
      );
      final result = terrainGenerator.generate(
        Vector2.all(15),
        Vector2(600, 800),
      );
      expect(result.length, gameSize.x + amountOfPowerUps);
    });
    test('prevent incorrect terrain creation', () {
      maxPowerupHeight = 10;
      expect(
        () {
          createTestGenerator(
            amountOfLandingSpots,
            amountOfPowerUps,
            maxPowerupHeight,
            gameSize,
          );
        },
        failsAssert('MaxPowerupHeight must be above size.y'),
      );
    });

    test('ensure terrain has all powerups', () {
      amountOfPowerUps = 15;
      final terrainGenerator = createTestGenerator(
        amountOfLandingSpots,
        amountOfPowerUps,
        maxPowerupHeight,
        gameSize,
      );
      final result = terrainGenerator.generate(
        Vector2.all(15),
        Vector2(600, 800),
      );
      expect(result.whereType<PowerupComponent>().length, amountOfPowerUps);
    });

    test('ensure terrain has all landing sports', () {
      amountOfLandingSpots = 15;
      final terrainGenerator = createTestGenerator(
        amountOfLandingSpots,
        amountOfPowerUps,
        maxPowerupHeight,
        gameSize,
      );
      final result = terrainGenerator.generate(
        Vector2.all(15),
        Vector2(600, 800),
      );
      expect(
        result.whereType<LineComponent>().where((line) => line.isGoal).length,
        amountOfLandingSpots,
      );
    });
  });
}

TerrainGenerator createTestGenerator(
  int amountOfLandingSpots,
  int amountOfPowerUps,
  int maxPowerupHeight,
  Vector2 gameSize,
) =>
    TerrainGenerator(
      seed: 'tesing rulez'.hashCode,
      amountOfLandingSpots: amountOfLandingSpots,
      amountOfPowerups: amountOfPowerUps,
      maxPowerupHeight: maxPowerupHeight,
      size: gameSize,
    );
