
import 'package:on_audio_query/on_audio_query.dart' hide SongModel;
import '../data/models/song_model.dart';
import 'dart:io';

class MusicScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<List<SongModel>> getSong() async {
    final hasPermission = await _audioQuery.permissionsStatus();

    if (!hasPermission) {
      throw Exception('Music permission not granted');
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    final result = <SongModel>[];

for (final song in songs) {
  if (song.isMusic != true ||
      song.data.isEmpty ||
      (song.duration ?? 0) <= 0) {
    continue;
  }

    final artwork = await _audioQuery.queryArtwork(
      song.id,
      ArtworkType.AUDIO,
      size: 500,
    );

    result.add(
      SongModel(
        id: song.id,
        title: song.title,
        artist: song.artist ?? 'Unknown Artist',
        album: song.album ?? 'Unknown Album',
        path: song.data,
        folder: File(song.data).parent.path.split(Platform.pathSeparator).last,
        duration: song.duration ?? 0,
        artwork: artwork,
      ),
    );
  }

  return result;
  }
}
