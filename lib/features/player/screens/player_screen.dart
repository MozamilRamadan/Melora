import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:music_player/core/theme/app_style.dart';
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyle.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          color: AppStyle.goldColor,
          iconSize: 30,
        ),
        title: const Column(
          children: [
            Text(
              'NOW PLAYING',
              style: TextStyle(
                color: AppStyle.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'ME L O R A',
              style: TextStyle(
                color: AppStyle.secondaryTextColor,
                fontSize: 9,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<SongModel?>(
        valueListenable: currentSong,
        builder: (context, song, _) {
          if (song == null) {
            return const Center(
              child: Text(
                'No song selected',
                style: TextStyle(color: AppStyle.secondaryTextColor),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final artworkSize =
                  (constraints.maxWidth * 0.72).clamp(190.0, 310.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: artworkSize + 18,
                        height: artworkSize + 18,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppStyle.goldLightColor,
                              AppStyle.goldColor,
                              AppStyle.purpleColor,
                              AppStyle.deepPurpleColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppStyle.purpleColor.withOpacity(0.32),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: AppStyle.goldColor.withOpacity(0.12),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: song.artwork != null &&
                                  song.artwork!.isNotEmpty
                              ? Image.memory(
                                  song.artwork!,
                                  width: artworkSize,
                                  height: artworkSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const _ArtworkPlaceholder(),
                                )
                              : const _ArtworkPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        song.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppStyle.textColor,
                          fontSize: 22,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppStyle.goldLightColor,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _ProgressControl(
                        audioPlayer: audioPlayer,
                        formatDuration: _formatDuration,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ModeButton(
                            icon: Icons.shuffle_rounded,
                            label: 'SHUFFLE',
                            active: shuffleEnabled,
                            onPressed: onShuffle,
                          ),
                          _ModeButton(
                            icon: repeatMode == 2
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            label: repeatMode == 2
                                ? 'REPEAT ONE'
                                : repeatMode == 1
                                    ? 'REPEAT ALL'
                                    : 'REPEAT',
                            active: repeatMode != 0,
                            onPressed: onRepeat,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: 'Previous',
                            onPressed: onPrevious,
                            icon: const Icon(Icons.skip_previous_rounded),
                            color: AppStyle.textColor,
                            iconSize: 38,
                          ),
                          StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playing = snapshot.data?.playing ?? false;
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppStyle.goldLightColor,
                                      AppStyle.goldColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppStyle.goldColor
                                          .withOpacity(0.28),
                                      blurRadius: 18,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  tooltip: playing ? 'Pause' : 'Play',
                                  onPressed: () {
                                    if (playing) {
                                      audioPlayer.pause();
                                    } else {
                                      audioPlayer.handler.play();
                                    }
                                  },
                                  icon: Icon(
                                    playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                  color: AppStyle.backgroundColor,
                                  iconSize: 38,
                                  padding: const EdgeInsets.all(15),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Next',
                            onPressed: onNext,
                            icon: const Icon(Icons.skip_next_rounded),
                            color: AppStyle.textColor,
                            iconSize: 38,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _VolumeControl(audioPlayer: audioPlayer),
                    ],
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

class _ProgressControl extends StatelessWidget {
  final AudioPlayerService audioPlayer;
  final String Function(Duration) formatDuration;

  const _ProgressControl({
    required this.audioPlayer,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: audioPlayer.positionStream,
      builder: (context, positionSnapshot) {
        final position = positionSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: audioPlayer.durationStream,
          builder: (context, durationSnapshot) {
            final duration = durationSnapshot.data ?? Duration.zero;
            final max = duration.inMilliseconds.toDouble();
            final value = position.inMilliseconds
                .toDouble()
                .clamp(0.0, max > 0 ? max : 1.0);

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppStyle.goldColor,
                    inactiveTrackColor: AppStyle.deepPurpleColor,
                    thumbColor: AppStyle.goldLightColor,
                    overlayColor: AppStyle.goldColor.withOpacity(0.14),
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: value,
                    max: max > 0 ? max : 1,
                    onChanged: max <= 0
                        ? null
                        : (next) => audioPlayer.seek(
                              Duration(milliseconds: next.round()),
                            ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: const TextStyle(
                          color: AppStyle.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        formatDuration(duration),
                        style: const TextStyle(
                          color: AppStyle.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _VolumeControl extends StatelessWidget {
  final AudioPlayerService audioPlayer;

  const _VolumeControl({required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: audioPlayer.volumeStream,
      initialData: audioPlayer.volume,
      builder: (context, snapshot) {
        final volume = (snapshot.data ?? 1.0).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppStyle.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppStyle.cardBorderColor),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: volume == 0 ? 'Unmute' : 'Mute',
                onPressed: () => audioPlayer.setVolume(
                  volume == 0 ? 1.0 : 0.0,
                ),
                icon: Icon(
                  volume == 0
                      ? Icons.volume_off_rounded
                      : volume < 0.5
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                ),
                color: AppStyle.goldColor,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppStyle.goldColor,
                    inactiveTrackColor: AppStyle.deepPurpleColor,
                    thumbColor: AppStyle.goldLightColor,
                    overlayColor: AppStyle.goldColor.withOpacity(0.12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    onChanged: audioPlayer.setVolume,
                  ),
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '${(volume * 100).round()}%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppStyle.secondaryTextColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 17,
        color: active ? AppStyle.goldColor : AppStyle.secondaryTextColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active ? AppStyle.goldColor : AppStyle.secondaryTextColor,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppStyle.artworkFallbackColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppStyle.goldColor,
        size: 90,
      ),
    );
  }
}
