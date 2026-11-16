import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/audio_handler.dart';

class AudioPlayerService {
  final MeloraAudioHandler handler;

  AudioPlayerService(this.handler);

  Duration get currentPosition => handler.currentPosition;
  double get volume => handler.volume;
  Stream<double> get volumeStream => handler.volumeStream;

  Future<void> setVolume(double value) => handler.setVolume(value);

  Future<void> restoreSong(
    String path, {
    String? title,
    String? artist,
    Uint8List? artwork,
    required Duration position,
  }) async {
    await handler.playFromPath(
      path,
      title: title,
      artist: artist,
      artwork: artwork,
      autoPlay: false,
    );
    await handler.seek(position);
  }

  Future<void> play(
    String path, {
    String? title,
    String? artist,
    Uint8List? artwork,
    bool autoPlay = true,
  }) {
    return handler.playFromPath(
      path,
      title: title,
      artist: artist,
      artwork: artwork,
      autoPlay: autoPlay,
    );
  }

  Future<void> pause() => handler.pause();
  Future<void> stop() => handler.stop();
  Future<void> dispose() async {}

  Stream<PlayerState> get playerStateStream => handler.playerStateStream;
  Stream<Duration?> get durationStream => handler.durationStream;
  Stream<Duration> get positionStream => handler.positionStream;

  Future<void> seek(Duration position) => handler.seek(position);
}
