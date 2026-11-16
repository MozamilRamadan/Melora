import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final int index;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.index,
    required this.isPlaying,
    required this.onTap,
  });

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = isPlaying ? AppStyle.goldColor : AppStyle.secondaryTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.mediumSpacing,
        vertical: 4,
      ),
      child: Material(
        color: isPlaying
            ? AppStyle.selectedSongColor
            : AppStyle.surfaceColor,
        borderRadius: BorderRadius.circular(AppStyle.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppStyle.borderRadius),
              border: Border.all(
                color: isPlaying
                    ? AppStyle.goldColor.withOpacity(0.55)
                    : AppStyle.cardBorderColor,
                width: 1,
              ),
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
                            errorBuilder: (context, error, stackTrace) =>
                                _ArtworkFallback(isPlaying: isPlaying),
                          )
                        : _ArtworkFallback(isPlaying: isPlaying),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying
                              ? AppStyle.goldColor
                              : AppStyle.textColor,
                          fontSize: AppStyle.titleSize,
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
                          fontSize: AppStyle.subtitleSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(song.duration),
                  style: TextStyle(
                    color: isPlaying
                        ? AppStyle.goldColor
                        : AppStyle.secondaryTextColor,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isPlaying ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                  color: accent,
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkFallback extends StatelessWidget {
  final bool isPlaying;

  const _ArtworkFallback({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.artworkFallbackColor,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        color: isPlaying ? AppStyle.goldColor : AppStyle.purpleColor,
        size: 28,
      ),
    );
  }
}
