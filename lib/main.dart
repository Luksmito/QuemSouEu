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
    final colorScheme =
        ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 3, 7, 27));
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.background,
          appBarTheme: AppBarTheme(backgroundColor: colorScheme.background),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                elevation: MaterialStateProperty.all<double>(10.0),
                shadowColor: MaterialStateProperty.all<Color>(
                    Colors.black.withOpacity(0.3)),
                foregroundColor:
                    MaterialStateProperty.all(colorScheme.onPrimary),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withAlpha(0)),),
          ),
          textTheme: TextTheme(
              bodyLarge: TextStyle(
                  fontFamily: 'SpicyRice',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer),
              bodyMedium: const TextStyle(
                  fontFamily: 'SpicyRice',
                  fontSize: 20,
                  fontWeight: FontWeight.normal),
              bodySmall: const TextStyle(
                  fontFamily: 'SpicyRice',
                  fontSize: 12,
                  fontWeight: FontWeight.normal),
              labelLarge: const TextStyle(
                fontSize: 12,
              )),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        routes: {
          '/hostGame': (context) => const HostGame(),
          '/findLobby': (context) => const FindLobby()
        });
  }
}
