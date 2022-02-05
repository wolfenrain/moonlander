import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

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
          (_random.nextBool() ? 1 : -1) * _random.nextDouble() * 10,
          max(_random.nextDouble(), 0.1) * 10,
        ),
        child: CircleParticle(
          radius: .15,
          //Random color between yellow and red
          paint: Paint()
            ..color =
                Color.lerp(Colors.yellow, Colors.red, _random.nextDouble())!,
        ),
      ),
    );
  }
}
