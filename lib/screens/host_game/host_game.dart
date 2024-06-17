import 'package:flutter/material.dart';
import 'package:quem_sou_eu/screens/host_game/host_game_form.dart';
import 'package:quem_sou_eu/theme/backgroud_theme.dart';

class HostGame extends StatelessWidget {
  const HostGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Hospedar jogo",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Container(
        decoration: backgroundTheme(context),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: HostGameForm(),
        ),
      ),
    );
  }
}
