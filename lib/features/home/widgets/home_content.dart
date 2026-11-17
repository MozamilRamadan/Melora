
import 'package:flutter/material.dart';

import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/favorites_service.dart';

import 'package:music_player/features/home/widgets/search_bar.dart';
import 'package:music_player/features/home/widgets/sort_button.dart';
import 'package:music_player/features/home/widgets/song_tile.dart';
import 'package:music_player/features/home/widgets/folder_filter.dart';

class HomeContent extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<SongModel> songs;
  final List<String> folders;
  final String selectedFolder;
  final String selectedSort;
  final FavoritesService favorites;

  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFolderChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<SongModel> onSongTap;
  final VoidCallback onRetry;
  final int? currentSongId;

  const HomeContent({
    super.key,
    required this.isLoading,
    required this.error,
    required this.songs,
    required this.folders,
    required this.selectedFolder,
    required this.selectedSort,
    required this.favorites,
    required this.onSearchChanged,
    required this.onFolderChanged,
    required this.onSortChanged,
    required this.onSongTap,
    required this.onRetry,
    required this.currentSongId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (songs.isEmpty) {
      return const Center(
        child: Text('No music found'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppStyle.mediumSpacing),
          child: SearchBarWidget(
            onChanged: onSearchChanged,
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
                  folders: folders,
                  selectedFolder: selectedFolder,
                  onChanged: onFolderChanged,
                ),
              ),
              SortButton(
                selectedSort: selectedSort,
                onSortChanged: onSortChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: songs.isEmpty
              ? const Center(
                  child: Text('No matching songs'),
                )
              : AnimatedBuilder(
                  animation: favorites,
                  builder: (context, child) {
                    return ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];

                        return SongTile(
                          song: song,
                          index: index,
                          isPlaying: song.id == currentSongId,
                          onTap: () => onSongTap(song),
                          isFavorite: favorites.isFavorite(song.id),
                          onFavoriteTap: () {
                            favorites.toggle(song.id);
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
