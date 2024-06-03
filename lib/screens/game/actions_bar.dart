import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/screens/utils/utils.dart';

class ActionsBar extends StatelessWidget {
  const ActionsBar({super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final RawDatagramSocket? socket;
  
  void restartGame(context) async {
    final result = await confirmationDialog("Reiniciar o jogo", "Deseja reiniciar o jogo?", context);
    if (!result!) return;
    GamePacket packet = gameData.myPlayer.createRestartGamePacket();
    if (gameData.myPlayer.isHost) {
      gameData.setGameState = GameState.waitingPlayers;
      gameData.sendPacketToAllPlayers(socket!, packet);
      gameData.restartGame();
    }
  }

  void changeToSelectOrderState() {
    GamePacket packet = gameData.myPlayer.createChangeStatePacket(GameState.waitingHostSelectOrder);
    if (gameData.myPlayer.isHost) {
      gameData.setGameState = GameState.waitingHostSelectOrder;
      gameData.sendPacketToAllPlayers(socket!, packet);
    }
  }

  void sendPacketPassTurn() {
    GamePacket packet = gameData.myPlayer.createPassTurnPacket();
    if (gameData.myPlayer.isHost) {
      gameData.sendPacketToAllPlayers(socket!, packet);
    } else {
      socket?.send(packet.toString().codeUnits, gameData.hostIP, gameData.gamePort);
    }
    gameData.passTurn();
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
        lista.add(
          Text("Ip: ${gameData.hostIP.address}\nPorta: ${gameData.gamePort}", style: Theme.of(context).textTheme.bodySmall)
        );
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
          Text("Vez de ${gameData.whosTurn}")
        );
      }
      if (gameData.myPlayer.isHost) {
        lista.add(ElevatedButton(
            onPressed: () => restartGame(context),
            child: Text("Reiniciar jogo",
                style: Theme.of(context).textTheme.bodySmall)));
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
