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
    final colorScheme =   ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 14, 2, 27));
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.background
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
            backgroundColor: MaterialStateProperty.resolveWith((state) {
              if (state.contains(MaterialState.pressed)) {
                return colorScheme.inversePrimary;
              } 
              return colorScheme.primary;
            })
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer
          ), 
          bodyMedium: const TextStyle(
            fontSize: 20,
          ),
          bodySmall: const TextStyle(
            fontSize: 12,
          ),
          labelLarge: const TextStyle(
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


