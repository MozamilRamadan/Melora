
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/music_scanner_service.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/features/player/screens/player_screen.dart';
import 'package:music_player/features/home/widgets/search_bar.dart';
import 'package:music_player/features/home/widgets/sort_button.dart';
import 'package:music_player/features/home/widgets/song_tile.dart';
import 'package:music_player/features/home/widgets/mini_player.dart';
import 'package:music_player/features/home/widgets/folder_filter.dart';
import 'package:music_player/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicScannerService _musicScanner = MusicScannerService();

  late final AudioPlayerService _audioPlayer;

  final ValueNotifier<SongModel?> _currentSong = ValueNotifier(null);

  StreamSubscription<PlayerState>? _playerStateSubscription;

  List<SongModel> _songs = [];
  List<SongModel> _playQueue = [];

  String _searchQuery = '';
  String _selectedFolder = 'All';
  String _selectedSort = 'title';

  bool _isLoading = true;
  bool _shuffleEnabled = false;

  String? _error;

  int? _currentSongId;
  int _queueIndex = -1;

  // 0 = Off, 1 = Repeat All, 2 = Repeat One
  int _repeatMode = 0;

  ProcessingState? _lastProcessingState;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayerService(audioHandler);
    _audioPlayer.handler.onNext = _playNextSong;
    _audioPlayer.handler.onPrevious = _playPreviousSong;

    _loadSongs();

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          _lastProcessingState != ProcessingState.completed) {
        _handleSongCompleted();
      }

      _lastProcessingState = state.processingState;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _musicScanner.getSong();

      if (!mounted) return;

      setState(() {
        _songs = songs;
        _playQueue = List.from(songs);
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<SongModel> get _filteredSongs {
    final result = _songs.where((song) {
      final matchesSearch = song.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      final matchesFolder = _selectedFolder == 'All' ||
          song.folder == _selectedFolder;

      return matchesSearch && matchesFolder;
    }).toList();

    switch (_selectedSort) {
      case 'duration':
        result.sort(
          (a, b) => a.duration.compareTo(b.duration),
        );
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

  List<String> get _folders {
    return _songs
        .map((song) => song.folder)
        .toSet()
        .toList()
      ..sort();
  }

  // Called when the user selects a song from the list.
  Future<void> _playSong(SongModel song) async {
    final visibleSongs = _filteredSongs;

    if (visibleSongs.isEmpty) return;

    _playQueue = List.from(visibleSongs);

    if (_shuffleEnabled) {
      _playQueue.shuffle();

      // Keep the selected song at the beginning of the queue.
      _playQueue.removeWhere((item) => item.id == song.id);
      _playQueue.insert(0, song);
    }

    await _playQueueSong(song);
  }

  // Plays a song that already belongs to the current queue.
  // Does not rebuild or shuffle the queue.
  Future<void> _playQueueSong(SongModel song) async {
    try {
      final index = _playQueue.indexWhere(
        (item) => item.id == song.id,
      );

      if (index == -1) return;

      await _audioPlayer.play(
        song.path,
        title: song.title,
        artist: song.artist,
        artwork: song.artwork,
      );

      if (!mounted) return;

      setState(() {
        _currentSongId = song.id;
        _queueIndex = index;
      });

      _currentSong.value = song;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play song: $e'),
        ),
      );
    }
  }

  Future<void> _playNextSong() async {
    if (_playQueue.isEmpty) return;

    final nextIndex = (_queueIndex + 1) % _playQueue.length;

    await _playQueueSong(_playQueue[nextIndex]);
  }

  Future<void> _playPreviousSong() async {
    if (_playQueue.isEmpty) return;

    final previousIndex =
        (_queueIndex - 1 + _playQueue.length) % _playQueue.length;

    await _playQueueSong(_playQueue[previousIndex]);
  }

  Future<void> _handleSongCompleted() async {
    if (_currentSongId == null || _playQueue.isEmpty) return;

    if (_repeatMode == 2) {
      final currentSong = _currentSong.value;

      if (currentSong != null) {
        await _playQueueSong(currentSong);
      }

      return;
    }

    if (_repeatMode == 1) {
      await _playNextSong();
      return;
    }

    // Repeat Off: stop at the end of the queue.
    if (_queueIndex < _playQueue.length - 1) {
      await _playNextSong();
    }
  }

  void _toggleShuffle() {
    final visibleSongs = _filteredSongs;

    setState(() {
      _shuffleEnabled = !_shuffleEnabled;

      if (_shuffleEnabled) {
        _playQueue = List.from(visibleSongs);

        final currentSong = _currentSong.value;

        if (currentSong != null) {
          _playQueue.removeWhere(
            (song) => song.id == currentSong.id,
          );

          _playQueue.shuffle();
          _playQueue.insert(0, currentSong);
        } else {
          _playQueue.shuffle();
        }
      } else {
        _playQueue = List.from(visibleSongs);
      }

      _queueIndex = _playQueue.indexWhere(
        (song) => song.id == _currentSongId,
      );
    });

    _audioPlayer.handler.setShuffleEnabled(_shuffleEnabled);
  }
  void _toggleRepeat() {
    setState(() {
      _repeatMode = (_repeatMode + 1) % 3;
    });

  _audioPlayer.handler.updateRepeatMode(_repeatMode);
}
  void _openPlayerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          currentSong: _currentSong,
          audioPlayer: _audioPlayer,
          onNext: _playNextSong,
          onPrevious: _playPreviousSong,
          onShuffle: _toggleShuffle,
          onRepeat: _toggleRepeat,
          shuffleEnabled: _shuffleEnabled,
          repeatMode: _repeatMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();

    _audioPlayer.handler.onNext = null;
    _audioPlayer.handler.onPrevious = null;

    _audioPlayer.dispose();
    _currentSong.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        title: const Text('Melora'),
      ),
      body: _buildBody(),
      bottomNavigationBar: ValueListenableBuilder<SongModel?>(
        valueListenable: _currentSong,
        builder: (context, song, child) {
          return MiniPlayer(
            currentSong: song,
            audioPlayer: _audioPlayer,
            onNext: _playNextSong,
            onPrevious: _playPreviousSong,
            onOpenPlayer: _openPlayerScreen,
            onShuffle: _toggleShuffle,
            onRepeat: _toggleRepeat,
            shuffleEnabled: _shuffleEnabled,
            repeatMode: _repeatMode,
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });

                _loadSongs();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_songs.isEmpty) {
      return const Center(
        child: Text('No music found'),
      );
    }

    final visibleSongs = _filteredSongs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(
            AppStyle.mediumSpacing,
          ),
          child: SearchBarWidget(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyle.mediumSpacing,
          ),
          child: Row(
            children: [
              Expanded(
                child: FolderFilter(
                  folders: _folders,
                  selectedFolder: _selectedFolder,
                  onChanged: (value) {
                    setState(() {
                      _selectedFolder = value;
                    });
                  },
                ),
              ),
              SortButton(
                selectedSort: _selectedSort,
                onSortChanged: (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: visibleSongs.isEmpty
              ? const Center(
                  child: Text('No matching songs'),
                )
              : ListView.builder(
                  itemCount: visibleSongs.length,
                  itemBuilder: (context, index) {
                    final song = visibleSongs[index];

                    return SongTile(
                      song: song,
                      index: index,
                      isPlaying: song.id == _currentSongId,
                      onTap: () => _playSong(song),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
