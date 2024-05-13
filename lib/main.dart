import 'package:flutter/material.dart';
import 'package:quem_sou_eu/screens/find_lobby/find_lobby.dart';
import 'package:quem_sou_eu/screens/host_game/host_game.dart';

import 'screens/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ), 
          bodyMedium: TextStyle(
            fontSize: 20,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
          )
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      routes: {
        '/hostGame': (context) => const HostGame(),
        '/findLobby': (context) => FindLobby()
      }
    );
  }
}


