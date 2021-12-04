import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///short hand function to all particel effects for Moonlander
class ParticelGenerator {
  static final Random _random = Random();

  ///Create engine particels
  static ParticleComponent createEngineParticle({required Vector2 position}) {
    return ParticleComponent(
      AcceleratedParticle(
        position: position,
        //Create a downards shooting particel
        speed: Vector2(
          _random.nextDouble() * 200 - 100,
          -max(_random.nextDouble(), 0.1) * 100,
        ),
        child: CircleParticle(
          radius: 1,
          //Random color between yellow and red
          paint: Paint()
            ..color =
                Color.lerp(Colors.yellow, Colors.red, _random.nextDouble())!,
        ),
      ),
    );
  }
}
