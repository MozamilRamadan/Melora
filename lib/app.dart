
import 'package:flutter/material.dart';
import 'package:music_player/features/home/screens/home_screen.dart';

class MeloraApp extends StatelessWidget{
    const MeloraApp({super.key});
    @override
    Widget build(BuildContext context){
        return MaterialApp(
            title: 'Melora',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF121212),
                useMaterial3: true
            ),
            home: const HomeScreen(),
        );
    }
}