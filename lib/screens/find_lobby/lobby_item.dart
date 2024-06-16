import 'package:flutter/material.dart';
import 'package:quem_sou_eu/screens/find_lobby/connect_to_lobby.dart';
import 'package:quem_sou_eu/screens/find_lobby/lobby_data.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';

class LobbyItem extends StatelessWidget {
  LobbyItem({super.key, required this.lobby});

  final LobbyData lobby;

  final myStyle = ButtonStyle(
      shape: MaterialStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)))));

  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: buttonContainerTheme(context),
      child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectToLobby(lobbyData: lobby) ));
          },
          style: myStyle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lobby.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Icon(
                      lobby.hasPassword ? Icons.lock : Icons.lock_open,
                      color: lobby.hasPassword ? Colors.red : Colors.green,
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tema: ${lobby.theme}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "Players: ${lobby.players}",
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
