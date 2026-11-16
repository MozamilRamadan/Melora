
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
  const PlayerScreen({
    super.key,
    required this.currentSong,
    required this.audioPlayer,
    required this.onNext,
    required this.onPrevious,
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
  builder: (context, currentSong, child) {
    if (currentSong == null) {
      return const Center(child: Text('No song selected'));
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QueryArtworkWidget(
            id: currentSong.id,
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
            currentSong.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(currentSong.artist),
          
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

                    final max = duration.inMilliseconds.toDouble();
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
                                      milliseconds: newValue.toInt(),
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

            const SizedBox(height: 20),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 45,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: onPrevious,
                ),
                const SizedBox(width: 40),
                
                StreamBuilder<PlayerState>(
                  stream: audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final isPlaying =
                        snapshot.data?.playing ?? false;

                    return IconButton(
                      iconSize: 64,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          audioPlayer.pause();
                        } else {
                          audioPlayer.play(currentSong.path);
                        }
                      },
                    );
                  },
                ),
                
                const SizedBox(width: 40),
                IconButton(
                  iconSize: 45,
                  icon: const Icon(Icons.skip_next),
                  onPressed: onNext,
                ),
              ],
            ),
          
        ],
      ),
    );
  },
),

    );
  }
}



 
      // body: Padding(
      //   padding: const EdgeInsets.all(24),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       QueryArtworkWidget(
      //         id: currentSong.id,
      //         type: ArtworkType.AUDIO,
      //         artworkWidth: 250,
      //         artworkHeight: 250,
      //         artworkFit: BoxFit.cover,
      //         nullArtworkWidget: const Icon(
      //           Icons.music_note,
      //           size: 120,
      //         ),
      //       ),

      //       const SizedBox(height: 30),

      //       Text(
      //         currentSong.title,
      //         style: const TextStyle(
      //           fontSize: 24,
      //           fontWeight: FontWeight.bold,
      //         ),
      //         textAlign: TextAlign.center,
      //       ),

      //       const SizedBox(height: 8),
      //       Text(currentSong.artist),

      //       const SizedBox(height: 30),

      //       StreamBuilder<Duration>(
      //         stream: audioPlayer.positionStream,
      //         builder: (context, positionSnapshot) {
      //           final position =
      //               positionSnapshot.data ?? Duration.zero;

      //           return StreamBuilder<Duration?>(
      //             stream: audioPlayer.durationStream,
      //             builder: (context, durationSnapshot) {
      //               final duration =
      //                   durationSnapshot.data ?? Duration.zero;

      //               final max = duration.inMilliseconds.toDouble();
      //               final value = position.inMilliseconds
      //                   .clamp(0, duration.inMilliseconds)
      //                   .toDouble();

      //               return Column(
      //                 children: [
      //                   Slider(
      //                     value: max > 0 ? value : 0,
      //                     max: max > 0 ? max : 1,
      //                     onChanged: max > 0
      //                         ? (newValue) {
      //                             audioPlayer.seek(
      //                               Duration(
      //                                 milliseconds: newValue.toInt(),
      //                               ),
      //                             );
      //                           }
      //                         : null,
      //                   ),
      //                   Row(
      //                     mainAxisAlignment:
      //                         MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(formatDuration(position)),
      //                       Text(formatDuration(duration)),
      //                     ],
      //                   ),
      //                 ],
      //               );
      //             },
      //           );
      //         },
      //       ),

      //       const SizedBox(height: 20),


      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           IconButton(
      //             iconSize: 45,
      //             icon: const Icon(Icons.skip_previous),
      //             onPressed: onPrevious,
      //           ),
      //           const SizedBox(width: 40),
                
      //           StreamBuilder<PlayerState>(
      //             stream: audioPlayer.playerStateStream,
      //             builder: (context, snapshot) {
      //               final isPlaying =
      //                   snapshot.data?.playing ?? false;

      //               return IconButton(
      //                 iconSize: 64,
      //                 icon: Icon(
      //                   isPlaying ? Icons.pause_circle : Icons.play_circle,
      //                 ),
      //                 onPressed: () {
      //                   if (isPlaying) {
      //                     audioPlayer.pause();
      //                   } else {
      //                     audioPlayer.play(currentSong.path);
      //                   }
      //                 },
      //               );
      //             },
      //           ),
                
      //           const SizedBox(width: 40),
      //           IconButton(
      //             iconSize: 45,
      //             icon: const Icon(Icons.skip_next),
      //             onPressed: onNext,
      //           ),
      //         ],
      //       ),
          
      //     ],
      //   ),
      // ),
    