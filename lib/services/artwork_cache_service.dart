import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class ArtworkCacheService {
  Future<Uint8List?> getArtwork({
    required int songId,
    required Future<Uint8List?> Function() loader,
  }) async {
    final directory = await getTemporaryDirectory();
    final cacheDirectory = Directory(
      '${directory.path}/melora_artwork',
    );

    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }

    final file = File('${cacheDirectory.path}/$songId.jpg');

    if (await file.exists()) {
      return file.readAsBytes();
    }

    final artwork = await loader();

    if (artwork != null) {
      await file.writeAsBytes(artwork, flush: true);
    }

    return artwork;
  }
}