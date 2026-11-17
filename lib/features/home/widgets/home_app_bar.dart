
import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';

enum _HomeMenuAction {
  playlists,
  favorites,
  about,
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPlaylistsTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback? onAboutTap;

  const HomeAppBar({
    super.key,
    required this.onPlaylistsTap,
    required this.onFavoritesTap,
    this.onAboutTap,
  });

  static const Color _gold = Color(0xFFFFC857);
  static const Color _purple = Color(0xFF9B35D5);
  static const Color _surface = Color(0xFF1A1022);
  static const Color _muted = Color(0xFFB9AFC1);

  void _handleMenuSelection(
    BuildContext context,
    _HomeMenuAction action,
  ) {
    switch (action) {
      case _HomeMenuAction.playlists:
        onPlaylistsTap();
        break;
      case _HomeMenuAction.favorites:
        onFavoritesTap();
        break;
      case _HomeMenuAction.about:
        onAboutTap?.call();
        break;
    }
  }

  PopupMenuItem<_HomeMenuAction> _menuItem({
    required _HomeMenuAction value,
    required IconData icon,
    required String title,
    required String subtitle,
    bool highlighted = false,
  }) {
    return PopupMenuItem<_HomeMenuAction>(
      value: value,
      height: 66,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: highlighted
                  ? _purple.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: highlighted ? _gold : _muted,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: _muted,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppStyle.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: 20,

      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [
                  _purple,
                  Color(0xFF35104D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _purple.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: _gold,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MELORA',
                style: TextStyle(
                  color: _gold,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'MUSIC PLAYER',
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: PopupMenuButton<_HomeMenuAction>(
            tooltip: 'More options',
            onSelected: (action) =>
                _handleMenuSelection(context, action),
            offset: const Offset(0, 12),
            color: _surface,
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(
                color: Color(0xFF40204F),
                width: 1,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<_HomeMenuAction>(
                enabled: false,
                height: 76,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: _gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Melora Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Your music space',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(height: 8),

              _menuItem(
                value: _HomeMenuAction.playlists,
                icon: Icons.queue_music_rounded,
                title: 'Playlists',
                subtitle: 'Your music collections',
              ),

              _menuItem(
                value: _HomeMenuAction.favorites,
                icon: Icons.favorite_rounded,
                title: 'Favorites',
                subtitle: 'Your favorite songs',
                highlighted: true,
              ),

              _menuItem(
                value: _HomeMenuAction.about,
                icon: Icons.info_outline_rounded,
                title: 'About Melora',
                subtitle: 'App information and developer',
              ),

              const PopupMenuDivider(height: 8),

              const PopupMenuItem<_HomeMenuAction>(
                enabled: false,
                height: 38,
                child: Center(
                  child: Text(
                    'MELORA  •  VERSION 1.0',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF40204F),
                ),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: _gold,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
