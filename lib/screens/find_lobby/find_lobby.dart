import 'package:flutter/material.dart';
import 'package:quem_sou_eu/screens/find_lobby/button_select_server.dart';

import 'package:quem_sou_eu/screens/find_lobby/local_lobby.dart';
import 'package:quem_sou_eu/screens/find_lobby/server_lobby.dart';

class FindLobby extends StatefulWidget {
  const FindLobby({super.key});

  @override
  State<FindLobby> createState() => _FindLobbyState();
}

class _FindLobbyState extends State<FindLobby> {
  bool servidor = true;

  void changeServerSource() {
    servidor = !servidor;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Buscar jogo",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 5, 30, 50),
        child: Column(
          children: [
            ButtonSelectServer(
                callback: changeServerSource, servidor: servidor),
            const SizedBox(height: 15,),
            !servidor ? LocalLobby() : const ServerLobby(),
          ],
        ),
      ),
    );
  }
}
