
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MeloraAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  Future<void> Function()? onNext;
  Future<void> Function()? onPrevious;
  Future<void> Function()? onShuffle;
  Future<void> Function()? onRepeat;

  bool shuffleEnabled = false;
  int repeatMode = 0;
  Duration get currentPosition => _player.position;


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
        mediaItem.add(current.copyWith(duration: duration));
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
    bool autoPlay = true,
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

    await _player.setFilePath(path);

    mediaItem.add(item);

    final duration = _player.duration;

    if (duration != null) {
      mediaItem.add(item.copyWith(duration: duration));
    }

    if (autoPlay) {
      unawaited(_player.play());
    }
  }

  void setShuffleEnabled(bool enabled) {
    shuffleEnabled = enabled;
    _updatePlaybackState();
  }

  void updateRepeatMode(int mode) {
    repeatMode = mode;
    _updatePlaybackState();
  }

  void _updatePlaybackState() {
    final playing = _player.playing;

    final repeatServiceMode = switch (repeatMode) {
      1 => AudioServiceRepeatMode.all,
      2 => AudioServiceRepeatMode.one,
      _ => AudioServiceRepeatMode.none,
    };

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.custom(
            androidIcon: 'drawable/ic_shuffle',
            label: shuffleEnabled ? 'Shuffle On' : 'Shuffle Off',
            name: 'toggleShuffle',
          ),
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.custom(
            androidIcon: repeatMode == 2
                ? 'drawable/ic_repeat_one'
                : 'drawable/ic_repeat',
            label: switch (repeatMode) {
              1 => 'Repeat All',
              2 => 'Repeat One',
              _ => 'Repeat Off',
            },
            name: 'toggleRepeat',
          ),
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
        shuffleMode: shuffleEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: repeatServiceMode,
      ),
    );
  }

  @override
  Future<void> play() async {
    await _player.play();
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

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case 'toggleShuffle':
        await onShuffle?.call();
        break;

      case 'toggleRepeat':
        await onRepeat?.call();
        break;
    }
  }
}
