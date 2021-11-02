import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:moonlander/main.dart';

final pauseButtonSize = Vector2.all(50);

class PauseComponent extends PositionComponent
    with Tappable, HasGameRef<MoonlanderGame> {
  ///
  PauseComponent({required Vector2 position})
      : super(position: position, size: pauseButtonSize);

  @override
  bool get isHud => true;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      position & size,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (gameRef.overlays.isActive('pause')) {
      gameRef.overlays.remove('pause');
    } else {
      gameRef.overlays.add('pause');
    }

    return super.onTapDown(info);
  }
}
