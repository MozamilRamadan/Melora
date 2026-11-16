
import 'dart:typed_data';

class SongModel {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final String folder;
  final int duration;
  final Uint8List? artwork;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.folder,
    required this.duration,
    this.artwork,
  });
}
