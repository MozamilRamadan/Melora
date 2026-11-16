
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackStorageService {
  static const String _songIdKey = 'last_song_id';
  static const String _positionKey = 'last_position';
  static const String _queueKey = 'playback_queue';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';

  Future<void> savePlaybackState({
    required int? songId,
    required int position,
    required List<int> queue,
    required bool shuffleEnabled,
    required int repeatMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (songId != null) {
      await prefs.setInt(_songIdKey, songId);
    }

    await prefs.setInt(_positionKey, position);
    await prefs.setStringList(
      _queueKey,
      queue.map((id) => id.toString()).toList(),
    );
    await prefs.setBool(_shuffleKey, shuffleEnabled);
    await prefs.setInt(_repeatKey, repeatMode);
  }

  Future<Map<String, dynamic>> loadPlaybackState() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'songId': prefs.getInt(_songIdKey),
      'position': prefs.getInt(_positionKey) ?? 0,
      'queue': (prefs.getStringList(_queueKey) ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
      'shuffleEnabled': prefs.getBool(_shuffleKey) ?? false,
      'repeatMode': prefs.getInt(_repeatKey) ?? 0,
    };
  }
}
