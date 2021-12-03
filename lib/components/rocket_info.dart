import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moonlander/components/rocket_component.dart';

/// Draw the stats of our rocket.
class RocketInfo extends PositionComponent with HasGameRef {
  /// Create new rocket info instance.
  RocketInfo(this._rocket) : super();

  final _textRenderer = TextPaint(
    style: const TextStyle(
      fontSize: 16,
      fontFamily: 'AldotheApache',
      color: Colors.white,
    ),
  );

  var _text = '';

  final RocketComponent _rocket;

  @override
  bool get isHud => true;

  String _guiNumber(double number) => number.toStringAsFixed(2);

  @override
  Future<void>? onLoad() {
    _text = 'Fuel: 100 % \n'
        'Vertical speed: -99.00\n'
        'Horizontal speed: -99.00';
    final textSize = _textRenderer.measureText(_text);
    size = textSize;
    position = Vector2(gameRef.size.x / 2 - size.x / 2, textSize.y / 3);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    final actualSpeed = _rocket.velocity.scaled(_rocket.speed.toDouble());
    _text = '''
Fuel: ${_guiNumber(_rocket.fuel)} %
Horizontal speed: ${_guiNumber(actualSpeed.x)}
Vertical speed: ${_guiNumber(actualSpeed.y * -1)}
''';
    super.update(dt);
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
