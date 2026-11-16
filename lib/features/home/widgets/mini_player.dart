
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/theme/app_style.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  final SongModel? currentSong;
  final AudioPlayerService audioPlayer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onOpenPlayer;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final bool shuffleEnabled;
  final int repeatMode;

  const MiniPlayer({
    super.key,
    required this.currentSong,
    required this.audioPlayer,
    required this.onNext,
    required this.onPrevious,
    required this.onOpenPlayer,
    required this.onShuffle,
    required this.onRepeat,
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final song = currentSong;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.mediumSpacing,
        vertical: AppStyle.smallSpacing,
      ),
      color: AppStyle.surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: song == null ? null : onOpenPlayer,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        song?.title ?? 'No song playing',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppStyle.textColor,
                          fontSize: AppStyle.titleSize,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<Duration>(
                  stream: audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position =
                        snapshot.data ?? Duration.zero;

                    return StreamBuilder<Duration?>(
                      stream: audioPlayer.durationStream,
                      builder: (context, durationSnapshot) {
                        final duration =
                            durationSnapshot.data ?? Duration.zero;

                        final max = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;

                        final value = position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, max);

                        return Column(
                          children: [
                            Slider(
                              value: value,
                              max: max,
                              onChanged: song == null
                                  ? null
                                  : (newValue) {
                                      audioPlayer.seek(
                                        Duration(
                                          milliseconds:
                                              newValue.round(),
                                        ),
                                      );
                                    },
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    color: AppStyle.secondaryTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    color: AppStyle.secondaryTextColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: song == null ? null : onPrevious,
                icon: const Icon(Icons.skip_previous),
                color: AppStyle.textColor,
              ),
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying =
                      snapshot.data?.playing ?? false;

                  return IconButton(
                    onPressed: song == null
                        ? null
                        : () {
                            if (isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.handler.play();
                            }
                          },
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: AppStyle.buttonSize,
                    color: AppStyle.primaryColor,
                  );
                },
              ),
              IconButton(
                onPressed: song == null ? null : onNext,
                icon: const Icon(Icons.skip_next),
                color: AppStyle.textColor,
              ),
              IconButton(
                onPressed: song == null ? null : onRepeat,
                icon: Icon(
                  repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                  color: repeatMode == 0
                      ? AppStyle.secondaryTextColor
                      : AppStyle.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
