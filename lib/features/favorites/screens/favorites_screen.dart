import 'package:flutter/material.dart';

import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  final List<SongModel> songs;
  final FavoritesService favorites;
  final ValueChanged<SongModel> onPlaySong;

  const FavoritesScreen({
    super.key,
    required this.songs,
    required this.favorites,
    required this.onPlaySong,
  });

  String _duration(int milliseconds) {
    final value = Duration(milliseconds: milliseconds);
    return '${value.inMinutes}:${value.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyle.backgroundColor,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: AppStyle.goldColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: AppStyle.goldColor),
      ),
      body: AnimatedBuilder(
        animation: favorites,
        builder: (context, _) {
          final favoriteSongs = songs
              .where((song) => favorites.isFavorite(song.id))
              .toList()
            ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

          if (favoriteSongs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppStyle.surfaceColor,
                        border: Border.all(color: AppStyle.cardBorderColor),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppStyle.goldColor,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No favorites yet',
                      style: TextStyle(
                        color: AppStyle.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart on a song to add it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppStyle.secondaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: favoriteSongs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final song = favoriteSongs[index];
              return Material(
                color: AppStyle.surfaceColor,
                borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  onTap: () => onPlaySong(song),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                      border: Border.all(color: AppStyle.cardBorderColor),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: SizedBox(
                            width: 54,
                            height: 54,
                            child: song.artwork != null && song.artwork!.isNotEmpty
                                ? Image.memory(
                                    song.artwork!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const _FallbackArt(),
                                  )
                                : const _FallbackArt(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppStyle.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppStyle.secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _duration(song.duration),
                          style: const TextStyle(
                            color: AppStyle.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove from favorites',
                          onPressed: () => favorites.remove(song.id),
                          icon: const Icon(Icons.favorite_rounded),
                          color: AppStyle.goldColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FallbackArt extends StatelessWidget {
  const _FallbackArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.artworkFallbackColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppStyle.goldColor,
        size: 28,
      ),
    );
  }
}
