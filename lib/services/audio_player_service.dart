
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/audio_handler.dart';
import 'dart:typed_data';

class AudioPlayerService {
  final MeloraAudioHandler handler;

  AudioPlayerService(this.handler);

  Future<void> play(
    String path, {
    String? title,
    String? artist,
    Uint8List? artwork,
  }) async {
    await handler.playFromPath(
      path,
      title: title,
      artist: artist,
      artwork: artwork,
    );
  }

  Future<void> pause() => handler.pause();

  Future<void> stop() => handler.stop();

  Future<void> dispose() async {}

  Stream<PlayerState> get playerStateStream =>
      handler.playerStateStream;

  Stream<Duration?> get durationStream =>
      handler.durationStream;

  Stream<Duration> get positionStream =>
      handler.positionStream;

  Future<void> seek(Duration position) =>
      handler.seek(position);
}
