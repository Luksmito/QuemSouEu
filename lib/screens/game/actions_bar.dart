import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class ActionsBar extends StatelessWidget {
  const ActionsBar({super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final RawDatagramSocket? socket;

  void changeToSelectOrderState() {
    GamePacket packet = gameData.myPlayer.createChangeStatePacket(GameState.waitingHostSelectOrder);
    socket?.send(packet.toString().codeUnits, InternetAddress(Server.multicastAddress), gameData.gamePort);
  }

  void sendPacketPassTurn() {
    GamePacket packet = gameData.myPlayer.createPassTurnPacket();
    socket?.send(packet.toString().codeUnits, InternetAddress(Server.multicastAddress), gameData.gamePort);
  }

  List<Widget> buildBar(BuildContext context) {
    List<Widget> lista = [];
    if (gameData.myPlayer.isHost) {
      if (gameData.isWaitingPlayers()) {
        lista.clear();
        lista.add(ElevatedButton(
            onPressed: changeToSelectOrderState,
            child: Text("Selecionar ordem",
                style: Theme.of(context).textTheme.bodySmall)));
      } 
    } else {
      if (gameData.isWaitingPlayers()) {
        lista.clear();
        lista.add(
          Text("Esperando jogadores...", style: Theme.of(context).textTheme.bodyMedium,)
        );
      } else if (gameData.isWaitingSelectOrder()) {
        lista.clear();
        lista.add(
          Text("Esperando host escolher a ordem...", style: Theme.of(context).textTheme.bodyMedium,)
        );
      }
    }
    if (gameData.isWaitingChooseToGuess() || gameData.iChoosedToGuess()) {
      lista.clear();
      lista.add(
        const Text("Esperando players...")
      );
    } else if (gameData.isGameRunning()) {
      lista.clear();
      if (gameData.isMyTurn) {
        lista.add(ElevatedButton(
            onPressed: sendPacketPassTurn,
            child: Text("Passar vez",
                style: Theme.of(context).textTheme.bodySmall)));
      } else {
        lista.add(
          Text("Vez de  ${gameData.whosTurn}")
        );
      }
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buildBar(context),
    );
  }
}
