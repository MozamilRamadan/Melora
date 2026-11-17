
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/audio_handler.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/music_scanner_service.dart';
import 'package:music_player/services/playback_storage_service.dart';

class HomeController extends ChangeNotifier {
  final MusicScannerService _musicScanner = MusicScannerService();
  final PlaybackStorageService _storage = PlaybackStorageService();

  late final AudioPlayerService audioPlayer;

  final ValueNotifier<SongModel?> currentSong = ValueNotifier(null);

  Timer? _playbackSaveTimer;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  List<SongModel> _songs = [];
  List<SongModel> _playQueue = [];

  String searchQuery = '';
  String selectedFolder = 'All';
  String selectedSort = 'title';

  bool isLoading = true;
  bool shuffleEnabled = false;

  String? error;
  int? currentSongId;

  int _queueIndex = -1;
  int repeatMode = 0;
  ProcessingState? _lastProcessingState;

  bool _disposed = false;

  HomeController(MeloraAudioHandler handler) {
    audioPlayer = AudioPlayerService(handler);

    handler.onNext = playNextSong;
    handler.onPrevious = playPreviousSong;
    handler.onShuffle = toggleShuffle;
    handler.onRepeat = toggleRepeat;

    _playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          _lastProcessingState != ProcessingState.completed) {
        handleSongCompleted();
      }

      _lastProcessingState = state.processingState;
    });

    _playbackSaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => savePlaybackState(),
    );
  }

  List<SongModel> get songs => List.unmodifiable(_songs);

  List<SongModel> get filteredSongs {
    final result = _songs.where((song) {
      final matchesSearch = song.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesFolder =
          selectedFolder == 'All' || song.folder == selectedFolder;

      return matchesSearch && matchesFolder;
    }).toList();

    switch (selectedSort) {
      case 'duration':
        result.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      default:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
        );
    }

    return result;
  }

  List<String> get folders =>
      _songs.map((song) => song.folder).toSet().toList()..sort();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadSongs() async {
    try {
      isLoading = true;
      error = null;
      _notify();

      final scannedSongs = await _musicScanner.getSong();
      final savedState = await _storage.loadPlaybackState();

      if (_disposed) return;

      final songsById = {
        for (final song in scannedSongs) song.id: song,
      };

      final savedQueueIds = savedState['queue'] as List<int>;

      final restoredQueue = savedQueueIds
          .map((id) => songsById[id])
          .whereType<SongModel>()
          .toList();

      final savedSongId = savedState['songId'] as int?;

      final restoredSong =
          savedSongId == null ? null : songsById[savedSongId];

      if (restoredSong != null &&
          !restoredQueue.any((song) => song.id == restoredSong.id)) {
        restoredQueue.insert(0, restoredSong);
      }

      if (restoredQueue.isEmpty) {
        restoredQueue.addAll(scannedSongs);
      }

      final restoredShuffle = savedState['shuffleEnabled'] as bool;
      final savedRepeatMode = savedState['repeatMode'] as int;

      final restoredRepeatMode =
          savedRepeatMode >= 0 && savedRepeatMode <= 2
              ? savedRepeatMode
              : 0;

      _songs = scannedSongs;
      _playQueue = restoredQueue;

      currentSongId = restoredSong?.id;

      _queueIndex = restoredSong == null
          ? -1
          : restoredQueue.indexWhere(
              (song) => song.id == restoredSong.id,
            );

      shuffleEnabled = restoredShuffle;
      repeatMode = restoredRepeatMode;
      currentSong.value = restoredSong;

      isLoading = false;
      error = null;

      audioPlayer.handler.setShuffleEnabled(restoredShuffle);
      audioPlayer.handler.updateRepeatMode(restoredRepeatMode);

      _notify();

      if (restoredSong != null) {
        final savedPosition = savedState['position'] as int;

        await audioPlayer.restoreSong(
          restoredSong.path,
          title: restoredSong.title,
          artist: restoredSong.artist,
          position: Duration(
            milliseconds: savedPosition > 0 ? savedPosition : 0,
          ),
        );
      }
    } catch (e) {
      if (_disposed) return;

      error = e.toString();
      isLoading = false;
      _notify();
    }
  }

  void updateSearch(String value) {
    searchQuery = value;
    _notify();
  }

  void updateFolder(String value) {
    selectedFolder = value;
    _notify();
  }

  void updateSort(String value) {
    selectedSort = value;
    _notify();
  }

  Future<void> playSong(SongModel song) async {
    final visibleSongs = filteredSongs;

    if (visibleSongs.isEmpty) return;

    _playQueue = List.from(visibleSongs);

    if (shuffleEnabled) {
      _playQueue.shuffle();
      _playQueue.removeWhere((item) => item.id == song.id);
      _playQueue.insert(0, song);
    }

    await playQueueSong(song);
  }

  Future<void> playPlaylist(List<SongModel> songs) async {
    if (songs.isEmpty) return;

    _playQueue = List<SongModel>.from(songs);

    await playQueueSong(_playQueue.first);
  }

  Future<void> playQueueSong(SongModel song) async {
    try {
      final index = _playQueue.indexWhere(
        (item) => item.id == song.id,
      );

      if (index == -1) return;

      await Permission.notification.request();

      await audioPlayer.play(
        song.path,
        title: song.title,
        artist: song.artist,
        artwork: song.artwork,
      );

      if (_disposed) return;

      currentSongId = song.id;
      _queueIndex = index;
      currentSong.value = song;

      _notify();
    } catch (e) {
      if (_disposed) return;
      rethrow;
    }
  }

  Future<void> playNextSong() async {
    if (_playQueue.isEmpty) return;

    final nextIndex = (_queueIndex + 1) % _playQueue.length;

    await playQueueSong(_playQueue[nextIndex]);
  }

  Future<void> playPreviousSong() async {
    if (_playQueue.isEmpty) return;

    final previousIndex =
        (_queueIndex - 1 + _playQueue.length) % _playQueue.length;

    await playQueueSong(_playQueue[previousIndex]);
  }

  Future<void> handleSongCompleted() async {
    if (currentSongId == null || _playQueue.isEmpty) return;

    if (repeatMode == 2) {
      final song = currentSong.value;
      if (song != null) await playQueueSong(song);
      return;
    }

    if (repeatMode == 1) {
      await playNextSong();
      return;
    }

    if (_queueIndex < _playQueue.length - 1) {
      await playNextSong();
    }
  }

  Future<void> toggleShuffle() async {
    final visibleSongs = filteredSongs;

    shuffleEnabled = !shuffleEnabled;

    if (shuffleEnabled) {
      _playQueue = List.from(visibleSongs);

      final song = currentSong.value;

      if (song != null) {
        _playQueue.removeWhere((item) => item.id == song.id);
        _playQueue.shuffle();
        _playQueue.insert(0, song);
      } else {
        _playQueue.shuffle();
      }
    } else {
      _playQueue = List.from(visibleSongs);
    }

    _queueIndex = _playQueue.indexWhere(
      (song) => song.id == currentSongId,
    );

    audioPlayer.handler.setShuffleEnabled(shuffleEnabled);

    _notify();
  }

  Future<void> toggleRepeat() async {
    repeatMode = (repeatMode + 1) % 3;

    audioPlayer.handler.updateRepeatMode(repeatMode);

    _notify();
  }

  Future<void> savePlaybackState() async {
    if (currentSongId == null || _playQueue.isEmpty) return;

    await _storage.savePlaybackState(
      songId: currentSongId,
      position: audioPlayer.currentPosition.inMilliseconds,
      queue: _playQueue.map((song) => song.id).toList(),
      shuffleEnabled: shuffleEnabled,
      repeatMode: repeatMode,
    );
  }

  @override
  void dispose() {
    _disposed = true;

    _playbackSaveTimer?.cancel();
    _playerStateSubscription?.cancel();

    audioPlayer.handler.onNext = null;
    audioPlayer.handler.onPrevious = null;
    audioPlayer.handler.onShuffle = null;
    audioPlayer.handler.onRepeat = null;

    savePlaybackState();

    currentSong.dispose();

    audioPlayer.dispose();

    super.dispose();
  }
}
