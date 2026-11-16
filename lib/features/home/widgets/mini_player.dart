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

  @override
  Widget build(BuildContext context) {
    final song = currentSong;

    if (song == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppStyle.surfaceColor,
            AppStyle.selectedSongColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppStyle.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: AppStyle.purpleColor.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onOpenPlayer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 8, 5),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: song.artwork != null && song.artwork!.isNotEmpty
                          ? Image.memory(
                              song.artwork!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const _MiniArtworkFallback(),
                            )
                          : const _MiniArtworkFallback(),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppStyle.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
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
                  IconButton(
                    tooltip: 'Shuffle',
                    visualDensity: VisualDensity.compact,
                    onPressed: onShuffle,
                    icon: const Icon(Icons.shuffle_rounded),
                    color: shuffleEnabled
                        ? AppStyle.goldColor
                        : AppStyle.secondaryTextColor,
                  ),
                  IconButton(
                    tooltip: 'Previous',
                    visualDensity: VisualDensity.compact,
                    onPressed: onPrevious,
                    icon: const Icon(Icons.skip_previous_rounded),
                    color: AppStyle.secondaryTextColor,
                  ),
                  StreamBuilder<PlayerState>(
                    stream: audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return IconButton(
                        tooltip: isPlaying ? 'Pause' : 'Play',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          if (isPlaying) {
                            audioPlayer.pause();
                          } else {
                            audioPlayer.handler.play();
                          }
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        color: AppStyle.goldColor,
                        iconSize: 29,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Next',
                    visualDensity: VisualDensity.compact,
                    onPressed: onNext,
                    icon: const Icon(Icons.skip_next_rounded),
                    color: AppStyle.textColor,
                  ),
                  IconButton(
                    tooltip: repeatMode == 2
                        ? 'Repeat One'
                        : repeatMode == 1
                            ? 'Repeat All'
                            : 'Repeat Off',
                    visualDensity: VisualDensity.compact,
                    onPressed: onRepeat,
                    icon: Icon(
                      repeatMode == 2
                          ? Icons.repeat_one_rounded
                          : Icons.repeat_rounded,
                    ),
                    color: repeatMode == 0
                        ? AppStyle.secondaryTextColor
                        : AppStyle.goldColor,
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<Duration>(
            stream: audioPlayer.positionStream,
            builder: (context, positionSnapshot) {
              final position =
                  positionSnapshot.data ?? Duration.zero;
              return StreamBuilder<Duration?>(
                stream: audioPlayer.durationStream,
                builder: (context, durationSnapshot) {
                  final duration =
                      durationSnapshot.data ?? Duration.zero;
                  final total = duration.inMilliseconds;
                  final current = position.inMilliseconds;
                  final progress = total > 0
                      ? (current / total).clamp(0.0, 1.0)
                      : 0.0;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 7),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2.5,
                        backgroundColor: AppStyle.deepPurpleColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppStyle.goldColor,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniArtworkFallback extends StatelessWidget {
  const _MiniArtworkFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.artworkFallbackColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppStyle.goldColor,
        size: 25,
      ),
    );
  }
}
