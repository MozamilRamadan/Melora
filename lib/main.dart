
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

import 'app.dart';
import 'services/audio_handler.dart';

late final MeloraAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => MeloraAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.melora.music_player.audio',
      androidNotificationChannelName: 'Melora Music',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const MeloraApp());
}
