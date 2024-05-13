import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/game/actions_bar.dart';
import 'package:quem_sou_eu/screens/game/player_list.dart';
import 'package:quem_sou_eu/screens/game/select_order.dart';
import 'package:quem_sou_eu/screens/game/select_to_guess.dart';
import 'package:android_multicast_lock/android_multicast_lock.dart';

class Game extends StatefulWidget {
  const Game({super.key, required this.player, required this.port});

  final Player player;
  final int port;
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late GameData gameData = GameData(widget.player, widget.port);
  RawDatagramSocket? socket;

  void initializeSocket() async {
    await Server.start(gameData.gamePort).then((RawDatagramSocket? result) {
      if (result != null) {
        socket = result;
        if (socket != null) {
          Server.startToListen(socket!, gameData.processPacket);
        }
        if (!widget.player.isHost) {
          GamePacket newPlayerPacket = widget.player.createNewPlayerPacket();
          socket!.send(newPlayerPacket.toString().codeUnits,
              InternetAddress(Server.multicastAddress), gameData.gamePort);
        }
      } else {
        Navigator.pop(context);
      }
    });
  }

  void showSelectOrder() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SelectOrder(gameData: gameData, socket: socket);
      },
    );
  }

  void showSelectToGuess() async {
    final toGuess = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return SelectToGuess(gameData: gameData, socket: socket);
      },
    );
    GamePacket packet = widget.player.createSetToGuessPacket(toGuess!);
    socket!.send(packet.toString().codeUnits, InternetAddress(Server.multicastAddress), gameData.gamePort);
    gameData.setGameState = GameState.iChoosedToGuess;
  }

  @override
  void initState() {
    super.initState();
    initializeSocket();
    if (Platform.isAndroid) {
      print("Pegando multicast");
      MulticastLock().acquire();
    }
    if (widget.player.isHost) {
      print("Você é um host");
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      print("Soltando multicast");
      MulticastLock().release();
    }
    super.dispose();
  }
  void handleGameState() {
    if (gameData.isWaitingSelectOrder() && gameData.myPlayer.isHost) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        showSelectOrder();
      });
    } else if (gameData.isWaitingChooseToGuess()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSelectToGuess();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: gameData,
        builder: (BuildContext context, Widget? child) {
          print(gameData.gameState.toString());
          handleGameState();
          return Scaffold(
            persistentFooterButtons: [
              ActionsBar(
                gameData: gameData,
                socket: socket,
              )
            ],
            body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlayerList(gameData: gameData)),
          );
        });
  }
}
