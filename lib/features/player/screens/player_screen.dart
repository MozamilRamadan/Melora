
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel;

import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/services/audio_player_service.dart';

class PlayerScreen extends StatelessWidget {
  final ValueListenable<SongModel?> currentSong;
  final AudioPlayerService audioPlayer;

  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;

  final bool shuffleEnabled;
  final int repeatMode;

  const PlayerScreen({
    super.key,
    required this.currentSong,
    required this.audioPlayer,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onRepeat,
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<SongModel?>(
        valueListenable: currentSong,
        builder: (context, song, child) {
          if (song == null) {
            return const Center(
              child: Text('No song selected'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkWidth: 250,
                  artworkHeight: 250,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    size: 120,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(song.artist),

                const SizedBox(height: 25),

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

                        final max =
                            duration.inMilliseconds.toDouble();

                        final value = position.inMilliseconds
                            .clamp(0, duration.inMilliseconds)
                            .toDouble();

                        return Column(
                          children: [
                            Slider(
                              value: max > 0 ? value : 0,
                              max: max > 0 ? max : 1,
                              onChanged: max > 0
                                  ? (newValue) {
                                      audioPlayer.seek(
                                        Duration(
                                          milliseconds:
                                              newValue.toInt(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatDuration(position)),
                                Text(formatDuration(duration)),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 25),

              Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        tooltip: 'Shuffle',
                        onPressed: onShuffle,
                        icon: Icon(
                          Icons.shuffle,
                          color: shuffleEnabled
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        iconSize: 32,
                        onPressed: onPrevious,
                        icon: const Icon(Icons.skip_previous),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<PlayerState>(
                        stream: audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data?.playing ?? false;

                          return IconButton(
                            iconSize: 48,
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                audioPlayer.pause();
                              } else {
                                audioPlayer.handler.play();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        iconSize: 32,
                        onPressed: onNext,
                        icon: const Icon(Icons.skip_next),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        tooltip: switch (repeatMode) {
                          1 => 'Repeat All',
                          2 => 'Repeat One',
                          _ => 'Repeat Off',
                        },
                        onPressed: onRepeat,
                        icon: Icon(
                          repeatMode == 2
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: repeatMode == 0
                              ? null
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
              
              ],
            ),
          );
        },
      ),
    );
  }
}
