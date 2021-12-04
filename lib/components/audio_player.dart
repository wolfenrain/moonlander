import 'package:flame_audio/audio_pool.dart';

//TODO add engine sounds

///Wraper to play any audio and load the assets
class MoonLanderAudioPlayer {
  late final AudioPool _explosion;
  late final AudioPool _engine;

  ///Load all audio assets
  Future<void> loadAssets() async {
    //Sound from https://opengameart.org/content/atari-booms by dklon
    _explosion = await _create(
      'atari_boom5.mp3',
    );
    //Sound based on https://opengameart.org/content/rocket-launch-pack by dklon
    _engine = await _create(
      'engine.mp3',
      minPlayers: 1,
      maxPlayers: 1,
    );
  }

  Future<AudioPool> _create(String name,
      {int minPlayers = 1, int? maxPlayers}) {
    return AudioPool.create(
      name,
      prefix: 'assets/sounds/',
      minPlayers: minPlayers,
      maxPlayers: maxPlayers,
    );
  }

  ///Play the default explosion sound
  void playExplosion() {
    _explosion.start();
  }

  ///Play engine sound
  void playEngine() {
    _engine.start(volume: 0.5);
  }
}
