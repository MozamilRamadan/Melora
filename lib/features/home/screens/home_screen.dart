
import 'package:flutter/material.dart';

import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/features/about/screens/about_screen.dart';
import 'package:music_player/features/favorites/screens/favorites_screen.dart';
import 'package:music_player/features/home/controllers/home_controller.dart';
import 'package:music_player/features/home/widgets/home_app_bar.dart';
import 'package:music_player/features/home/widgets/home_content.dart';
import 'package:music_player/features/home/widgets/mini_player.dart';
import 'package:music_player/features/player/screens/player_screen.dart';
import 'package:music_player/features/playlists/screens/playlists_screen.dart';
import 'package:music_player/main.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:music_player/services/playlists_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FavoritesService _favorites = FavoritesService();
  final PlaylistsService _playlists = PlaylistsService();

  late final HomeController _controller;

  @override
  void initState() {
    super.initState();

    _favorites.load();
    _playlists.load();

    _controller = HomeController(audioHandler);
    _controller.loadSongs();
  }

  Future<void> _handlePlaySong(SongModel song) async {
    try {
      await _controller.playSong(song);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play song: $e'),
        ),
      );
    }
  }

  Future<void> _handlePlayPlaylist(List<SongModel> songs) async {
    try {
      await _controller.playPlaylist(songs);

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to play playlist: $e'),
        ),
      );
    }
  }

  void _openPlayerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          currentSong: _controller.currentSong,
          audioPlayer: _controller.audioPlayer,
          onNext: _controller.playNextSong,
          onPrevious: _controller.playPreviousSong,
          onShuffle: _controller.toggleShuffle,
          onRepeat: _controller.toggleRepeat,
          shuffleEnabled: _controller.shuffleEnabled,
          repeatMode: _controller.repeatMode,
        ),
      ),
    );
  }

  void _openFavoritesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          songs: _controller.songs,
          favorites: _favorites,
          onPlaySong: (song) {
            Navigator.pop(context);
            _handlePlaySong(song);
          },
        ),
      ),
    );
  }

  void _openPlaylistsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistsScreen(
          songs: _controller.songs,
          playlists: _playlists,
          onPlayPlaylist: _handlePlayPlaylist,
        ),
      ),
    );
  }

  void _openAboutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _favorites.dispose();
    _playlists.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,

      appBar: HomeAppBar(
        onPlaylistsTap: _openPlaylistsScreen,
        onFavoritesTap: _openFavoritesScreen,
        onAboutTap: _openAboutScreen,
      ),

      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return HomeContent(
            isLoading: _controller.isLoading,
            error: _controller.error,
            songs: _controller.filteredSongs,
            folders: _controller.folders,
            selectedFolder: _controller.selectedFolder,
            selectedSort: _controller.selectedSort,
            favorites: _favorites,
            currentSongId: _controller.currentSongId,
            onSearchChanged: _controller.updateSearch,
            onFolderChanged: _controller.updateFolder,
            onSortChanged: _controller.updateSort,
            onSongTap: _handlePlaySong,
            onRetry: _controller.loadSongs,
          );
        },
      ),

      bottomNavigationBar: ValueListenableBuilder<SongModel?>(
        valueListenable: _controller.currentSong,
        builder: (context, song, child) {
          return MiniPlayer(
            currentSong: song,
            audioPlayer: _controller.audioPlayer,
            onNext: _controller.playNextSong,
            onPrevious: _controller.playPreviousSong,
            onOpenPlayer: _openPlayerScreen,
            onShuffle: _controller.toggleShuffle,
            onRepeat: _controller.toggleRepeat,
            shuffleEnabled: _controller.shuffleEnabled,
            repeatMode: _controller.repeatMode,
          );
        },
      ),
    );
  }
}
