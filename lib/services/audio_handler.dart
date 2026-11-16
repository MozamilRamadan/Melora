
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MeloraAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;

  MeloraAudioHandler() {
    _player.playbackEventStream.listen((event) {
      _updatePlaybackState();
    });

    _player.playerStateStream.listen((state) {
      _updatePlaybackState();
    });

    _player.durationStream.listen((duration) {
      final current = mediaItem.valueOrNull;

      if (current != null && duration != null) {
        mediaItem.add(
          current.copyWith(duration: duration),
        );
      }
    });
  }

  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  Stream<Duration?> get durationStream =>
      _player.durationStream;

  Stream<Duration> get positionStream =>
      _player.positionStream;


  
  Future<void> playFromPath(
    String path, {
    String? title,
    String? artist,
    Uint8List? artwork,
  }) async {
    Uri? artworkUri;

    if (artwork != null) {
      final file = File(
        '${Directory.systemTemp.path}/melora_${path.hashCode}.jpg',
      );

      await file.writeAsBytes(artwork, flush: true);
      artworkUri = Uri.file(file.path);
    }

    final item = MediaItem(
      id: path,
      title: title ?? 'Unknown Title',
      artist: artist ?? 'Unknown Artist',
      artUri: artworkUri,
    );
    
    mediaItem.add(null);
    mediaItem.add(item);

    await _player.setFilePath(path);

    final duration = _player.duration;

    if (duration != null) {
      mediaItem.add(item.copyWith(duration: duration));
    }

    unawaited(_player.play());
  }
    
  void _updatePlaybackState() {
    final playing = _player.playing;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        updateTime: DateTime.now(),
        speed: _player.speed,
      ),
    );
  }
    
  @override
  Future<void> play() async {
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }
@override
Future<void> skipToNext() async {
  await onNext?.call();
}

@override
Future<void> skipToPrevious() async {
  await onPrevious?.call();
}

}
