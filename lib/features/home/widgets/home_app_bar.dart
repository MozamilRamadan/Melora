
import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPlaylistsTap;
  final VoidCallback onFavoritesTap;

  const HomeAppBar({
    super.key,
    required this.onPlaylistsTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppStyle.backgroundColor,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Melora',
        style: TextStyle(
          color: AppStyle.primaryColor,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Playlists',
          onPressed: onPlaylistsTap,
          icon: const Icon(Icons.queue_music_rounded),
          color: AppStyle.goldColor,
        ),
        IconButton(
          tooltip: 'Favorites',
          onPressed: onFavoritesTap,
          icon: const Icon(Icons.favorite_rounded),
          color: AppStyle.goldColor,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
