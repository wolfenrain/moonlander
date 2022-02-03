// ignore_for_file: cascade_invocations

import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonlander/game_state.dart';
import 'package:moonlander/main.dart';

final fixedGameSize = Vector2(
  800,
  600,
);

final moonLanderGameTester = FlameTester(
  MoonlanderGame.new,
  gameSize: fixedGameSize,
);

void main() {
  group('game tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    //Define what should run before and after each test
    setUp(() {
      GameState.seed = 'Testing rocks';
    });

    tearDown(() {
      GameState.currentLevel = null;
      GameState.playState = PlayingState.playing;
      GameState.lastScore = null;
    });

    moonLanderGameTester.widgetTest('game widget can be created',
        (game, tester) async {
      expect(find.byGame<MoonlanderGame>(), findsOneWidget);
    });

    moonLanderGameTester.test('children loaded', (game) async {
      expect(game.children.length, 5);
    });

    moonLanderGameTester.test('rocket at the right position', (game) async {
      final rocketStart = game.size.scaled(0.5);
      expect(
        game.rocket.position,
        closeToVector(rocketStart.x, rocketStart.y),
      );
    });

    moonLanderGameTester.test('rocket starts with full tank', (game) async {
      expectDouble(game.rocket.fuel, 100);
    });
  });
}
