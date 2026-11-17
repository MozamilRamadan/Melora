import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores favorite song IDs locally on the device.
class FavoritesService extends ChangeNotifier {
  static const String _storageKey = 'melora_favorite_song_ids';

  final Set<int> _favoriteIds = <int>{};
  bool _isLoaded = false;

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoaded => _isLoaded;

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds
      ..clear()
      ..addAll(
        (prefs.getStringList(_storageKey) ?? <String>[])
            .map(int.tryParse)
            .whereType<int>(),
      );
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggle(int songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  Future<void> remove(int songId) async {
    if (_favoriteIds.remove(songId)) {
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _storageKey,
        _favoriteIds.map((id) => id.toString()).toList(),
      );
    }
  }
}
