import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/components/rocket_component.dart';

/// Draw the stats of our rocket.
class RocketInfo extends PositionComponent with HasGameRef {
  /// Create new rocket info instance.
  RocketInfo(this._rocket) : super();

  final _textRenderer = TextPaint(
    style: const TextStyle(
      fontSize: 20,
      fontFamily: 'AldotheApache',
      color: Colors.white,
    ),
  );

  var _text = '';

  final RocketComponent _rocket;

  String _guiNumber(double number) => number.toStringAsFixed(2);

  @override
  Future<void>? onLoad() {
    _text = 'Fuel: 100 % \n'
        'Vertical speed: -99.00\n'
        'Horizontal speed: -99.00';

    positionType = PositionType.viewport;
    resize();
    return super.onLoad();
  }

  ///Set the size and position based on text and screen
  void resize() {
    final textSize = _textRenderer.measureText(
      'Fuel: 100 % \n'
      'Vertical speed: -99.00\n'
      'Horizontal speed: -99.00',
    );
    size = textSize;
    final screenSize = gameRef.canvasSize;
    position = Vector2(screenSize.x / 2 - size.x / 2, textSize.y / 3);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final actualSpeed = _rocket.body.linearVelocity;
    _text = '''
Fuel: ${_guiNumber(_rocket.fuel)} %
Horizontal speed: ${_guiNumber(actualSpeed.x)}
Vertical speed: ${_guiNumber(actualSpeed.y)}
''';
  }

  @override
  void render(Canvas canvas) {
    final pos = Vector2.zero();
    _text.split('\n').forEach((line) {
      _textRenderer.render(canvas, line, pos);
      pos.y += size.y / 3;
    });

    super.render(canvas);
  }
}
