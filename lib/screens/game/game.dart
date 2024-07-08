import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/game_client.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/game/actions_bar.dart';
import 'package:quem_sou_eu/screens/game/player_list.dart';
import 'package:quem_sou_eu/screens/game/select_order.dart';
import 'package:quem_sou_eu/screens/game/select_to_guess.dart';
import 'package:quem_sou_eu/theme/backgroud_theme.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Game extends StatefulWidget {
  const Game({
    super.key,
    required this.player,
    required this.port,
    required this.hostIP,
    required this.lobbyName,
    required this.theme,
    required this.servidor,
  });

  final Player player;
  final int port;
  final InternetAddress hostIP;
  final String lobbyName;
  final String theme;
  final bool servidor;
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late GameData gameData = GameData(widget.player, widget.port, widget.hostIP,
      widget.lobbyName, widget.theme, widget.servidor);
  var socket;
  double chatPadding = 0;

  void initializeSocket() async {
    if (widget.servidor) {
      socket = GameClient(
          Server.addressServer, Server.portServer, gameData.processPacketLocal);
      await socket.connect();
      GamePacket newPlayerPacket = widget.player.createNewPlayerPacket();
      newPlayerPacket.lobbyName = gameData.lobbyName;
      socket.write(newPlayerPacket.toString());
    } else {
      await Server.start(gameData.gamePort, widget.player.myIP)
          .then((RawDatagramSocket? result) {
        if (result != null) {
          socket = result;
          if (socket != null) {
            Server.startToListen(socket!, gameData.processPacketLocal);
          }
          if (!widget.player.isHost) {
            GamePacket newPlayerPacket = widget.player.createNewPlayerPacket();
            socket!.send(newPlayerPacket.toString().codeUnits, widget.hostIP,
                gameData.gamePort);
          }
        } else {
          Navigator.pop(context);
        }
      });
    }
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
    final toGuess = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectToGuess(gameData: gameData, socket: socket)));
    GamePacket packet = widget.player.createSetToGuessPacket(toGuess!);
    gameData.setToGuess(packet);
    if (widget.player.isHost && !gameData.isServer) {
      gameData.sendPacketToAllPlayers(socket!, packet);
      if (gameData.isAllPlayersToGuessSetted()) {
        print("Todos selecionaram toGuess");
        packet =
            gameData.myPlayer.createChangeStatePacket(GameState.gameStarting);
        gameData.sendPacketToAllPlayers(socket!, packet);
        gameData.setGameState = GameState.gameStarting;
      }
    } else {
      if (gameData.isServer) {
        packet.lobbyName = gameData.lobbyName;
        socket.write(packet.toString());
      } else {
        socket!.send(
            packet.toString().codeUnits, gameData.hostIP, gameData.gamePort);
      }
    }
    gameData.setGameState = GameState.iChoosedToGuess;
  }

  @override
  void initState() {
    super.initState();
    initializeSocket();
    if (widget.player.isHost) {
      print("Você é um host");
    }
  }

  @override
  void dispose() {
    if (!widget.servidor) {
      gameData.sendPacketToAllPlayers(
          socket!, widget.player.createQuitGamePacket());
      socket!.close();
    } else {
      socket.close();
    }
    super.dispose();
  }

  void handleGameState() {
    if (gameData.quitGame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context, "Host saiu");
      });
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: gameData,
        builder: (BuildContext context, Widget? child) {
          handleGameState();
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !gameData.disconnected
                      ? Text(
                          widget.lobbyName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : Row(
                          children: [
                            Text(
                              "Reconectando...",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.red),
                            )
                          ],
                        ),
                  Text(
                    "Tema: ${widget.theme}",
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
            ),
            persistentFooterButtons: [
              Padding(
                padding: EdgeInsets.only(bottom: chatPadding),
                child: ActionsBar(
                  gameData: gameData,
                  socket: socket,
                ),
              )
            ],
            body: Container(
              decoration: backgroundTheme(context),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PlayerList(gameData: gameData)),
            ),
          );
        });
  }
}
