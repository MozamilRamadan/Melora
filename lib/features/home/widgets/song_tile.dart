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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 32,
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: AppStyle.secondaryTextColor,
            ),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isPlaying
              ? AppStyle.primaryColor
              : AppStyle.textColor,
          fontSize: AppStyle.titleSize,
        ),
      ),
      subtitle: Text(
        song.album,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppStyle.secondaryTextColor,
        ),
      ),
      trailing: Icon(
        isPlaying ? Icons.equalizer : Icons.play_arrow,
        color: AppStyle.primaryColor,
      ),
    );
  }
}