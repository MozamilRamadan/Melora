import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:music_player/data/models/song_playlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistsService extends ChangeNotifier {
  static const _key = 'melora_playlists_v1';
  final List<SongPlaylist> _items = [];
  List<SongPlaylist> get playlists => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _items
      ..clear()
      ..addAll(raw == null ? <SongPlaylist>[] : (jsonDecode(raw) as List<dynamic>).map((e) => SongPlaylist.fromJson(Map<String, dynamic>.from(e as Map))));
    notifyListeners();
  }

  Future<SongPlaylist> create(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Playlist name cannot be empty');
    final item = SongPlaylist(id: DateTime.now().microsecondsSinceEpoch.toString(), name: clean, songIds: [], createdAt: DateTime.now());
    _items.insert(0, item);
    await _save();
    notifyListeners();
    return item;
  }

  Future<void> rename(String id, String name) async {
    final item = _find(id);
    if (item == null || name.trim().isEmpty) return;
    item.name = name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addSong(String id, int songId) async {
    final item = _find(id);
    if (item == null || item.songIds.contains(songId)) return;
    item.songIds.add(songId);
    await _save();
    notifyListeners();
  }

  Future<void> removeSong(String id, int songId) async {
    final item = _find(id);
    if (item == null) return;
    item.songIds.remove(songId);
    await _save();
    notifyListeners();
  }

  SongPlaylist? _find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }
}
