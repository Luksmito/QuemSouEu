import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';

class GameData with ChangeNotifier {
  final Player myPlayer;
  final List<Player> players = [];
  final int gamePort;
  final InternetAddress hostIP;
  final String lobbyName;
  final String theme;
  final bool isServer;

  GameState gameState = GameState.waitingPlayers;
  late bool onLobby;
  bool isMyTurn = false;
  String whosTurn = "";
  bool quitGame = false;
  List<String> messages = [];
  int notReadMessages = 0;

  void resetReadMessages() {
    notReadMessages = 0;
    notifyListeners();
  }

  Map<String, dynamic> canConnect = {
    "canConnect": false,
    "nickUnavailable": false,
    "changed": false,
    "lobbyName": "",
    "theme": ""
  };

  GameData(this.myPlayer, this.gamePort, this.hostIP, this.lobbyName,
      this.theme, this.isServer) {
    players.add(myPlayer);
    onLobby = myPlayer.isHost;
  }

  void addMessage(String message) {
    messages.add(message);
    notifyListeners();
  }

  int findIndexNextPlayer(String nick) {
    for (int i = 0; i < players.length; i++) {
      if (myPlayer.nick == players[i].nick) {
        return (i + 1) % players.length;
      }
    }
    return 0;
  }

  void addPlayer(Player player) {
    players.add(player);
  }

  set setGameState(GameState newGameState) {
    gameState = newGameState;
    notifyListeners();
  }

  void sendPacketToAllPlayers(socket, GamePacket packet) {
    for (var player in players) {
      print("Enviando para $player");
      if (player.nick != myPlayer.nick) {
        socket.send(packet.toString().codeUnits, player.myIP, gamePort);
      }
    }
  }

  List<Map<String, String>> generatePlayersInLobby() {
    return List<Map<String, String>>.generate(
        players.length,
        (index) =>
            {"nick": players[index].nick, "ip": players[index].myIP.address});
  }

  void processNewPlayerPacket(GamePacket packet, socket) {
    if (onLobby) {
      print("Adicionando player ${packet.playerNick}");
      if (packet.newPlayerNick != myPlayer.nick) {
        addPlayer(Player(packet.newPlayerNick!, packet.playerIP));
      }

      if (myPlayer.isHost && !isServer) {
        print(
            "Host enviando para o novo player o pacote com os players da sala");
        GamePacket gamePacket = GamePacket(
            fromHost: true,
            playerNick: myPlayer.nick,
            playerIP: myPlayer.myIP,
            type: PacketType.sendPlayersAlreadyInLobby,
            playersAlreadyInLobby: generatePlayersInLobby());

        print(gamePacket.toString());
        socket.send(gamePacket.toString().codeUnits, packet.playerIP, gamePort);
        gamePacket = GamePacket(
          fromHost: true,
          playerNick: myPlayer.nick,
          newPlayerNick: packet.newPlayerNick,
          playerIP: packet.playerIP,
          type: PacketType.newPlayer,
        );
        sendPacketToAllPlayers(socket, packet);
      }
    }
    print("ESPERANDO");
    Future.delayed(const Duration(seconds: 2));
  }

  void setToGuess(newPacket) {
    for (var player in players) {
      if (player.nick == newPacket.playerNick) {
        player.toGuess = newPacket.toGuess;
        player.image = newPacket.image;
        break;
      }
    }
  }

  bool isAllPlayersToGuessSetted() {
    for (var player in players) {
      if (player.toGuess == null) {
        return false;
      }
    }
    return true;
  }

  void setPlayerOrder(List<String> playerOrder) {
    for (int i = 0; i < players.length; i++) {
      for (int j = i; j < players.length; j++) {
        if (playerOrder[i] == players[j].nick) {
          var aux = players[i];
          players[i] = players[j];
          players[j] = aux;
        }
      }
    }
  }

  void processPacketLocal(String packet, socket) {
    print("Packet Received $packet");
    print("Sou host?: ${myPlayer.isHost}");
    GamePacket newPacket = GamePacket.fromString(packet);
    if (newPacket.playerNick == myPlayer.nick &&
        newPacket.type != PacketType.setToGuess &&
        newPacket.type != PacketType.restartGame) {
      return;
    }
    switch (newPacket.type) {
      case PacketType.packetResponse:
        if (newPacket.response != "SUCCESS") {
          quitGame = true;
        }
        break;
      case PacketType.newPlayer:
        if (isWaitingPlayers() && newPacket.newPlayerNick != myPlayer.nick) {
          processNewPlayerPacket(newPacket, socket);
        }
        break;
      case PacketType.findLobby:
        if (myPlayer.isHost) {
          final nicks =
              List.generate(players.length, (index) => players[index].nick);
          GamePacket response = GamePacket(
            playerIP: myPlayer.myIP,
            fromHost: true,
            playerNick: myPlayer.nick,
            theme: theme,
            lobbyName: lobbyName,
            type: PacketType.findLobbyResponse,
          );
          response.response =
              nicks.contains(newPacket.playerNick) ? "nick indisponivel" : "ok";
          print("Enviando resposta para ${newPacket.playerIP.address}:6666");
          socket.send(response.toString().codeUnits, newPacket.playerIP, 6666);
        }
      case PacketType.findLobbyResponse:
        if (!onLobby && newPacket.fromHost) {
          canConnect["changed"] = true;
          if (newPacket.response == "ok") {
            canConnect["canConnect"] = true;
            canConnect["lobbyName"] = newPacket.lobbyName;
            canConnect["theme"] = newPacket.theme;
          } else if (newPacket.response == "nick indisponivel") {
            canConnect["nickUnavailable"] = true;
          }
          socket.close();
        }
      case PacketType.sendPlayersAlreadyInLobby:
        if (!onLobby) {
          print("Recebendo players já cadastrados");
          for (int i = 0; i < newPacket.playersAlreadyInLobby!.length; i++) {
            var nick = newPacket.playersAlreadyInLobby![i]["nick"]!;
            var ip = newPacket.playersAlreadyInLobby![i]["ip"]!;
            if (nick != myPlayer.nick) {
              print("Player Recebido ${newPacket.playersAlreadyInLobby![i]}");

              addPlayer(Player(nick, InternetAddress(ip)));
            }
          }
          onLobby = true;
        }
        break;
      case PacketType.gameStateChange:
        gameState = newPacket.newGameState!;
        if (gameState == GameState.waitingPlayerChooseToGuess) {
          if (newPacket.playerOrder != null) {
            setPlayerOrder(newPacket.playerOrder!);
          }
        } else if (gameState == GameState.gameStarting) {
          whosTurn = players[0].nick;
          isMyTurn = whosTurn == myPlayer.nick;
        }
        break;
      case PacketType.quitGame:
        players.removeWhere((element) => element.nick == newPacket.playerNick);
        if (newPacket.fromHost) {
          quitGame = true;
        }
        break;
      case PacketType.setToGuess:
        setToGuess(newPacket);
        if (myPlayer.isHost && !isServer) {
          sendPacketToAllPlayers(socket, newPacket);
          if (isAllPlayersToGuessSetted()) {
            GamePacket sendPacket = GamePacket(
                fromHost: true,
                playerNick: myPlayer.nick,
                playerIP: myPlayer.myIP,
                type: PacketType.gameStateChange,
                newGameState: GameState.gameStarting);
            setGameState = GameState.gameStarting;
            sendPacketToAllPlayers(socket, sendPacket);
            whosTurn = players[0].nick;
            isMyTurn = whosTurn == myPlayer.nick;
            notifyListeners();
          }
        }
        return;
      case PacketType.passTurn:
        passTurn();
        if (myPlayer.isHost && !isServer) {
          sendPacketToAllPlayers(socket, newPacket);
        }
        return;
      case PacketType.restartGame:
        restartGame();
        break;
      case PacketType.playerDisconnect:
        players.removeWhere((player) => player.nick == newPacket.playerNick);
        break;
      case PacketType.chatMessage:
        messages.add(newPacket.response!);
        notReadMessages += 1;
        if (myPlayer.isHost && !isServer) {
          sendPacketToAllPlayers(socket, newPacket);
        }
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void passTurn() {
    int index = (players.indexWhere((player) => player.nick == whosTurn) + 1) %
        players.length;
    whosTurn = players[index].nick;
    isMyTurn = whosTurn == myPlayer.nick;
    notifyListeners();
  }

  void printPlayers() {
    for (Player player in players) {
      print("Nick: ${player.nick}");
    }
  }

  bool isWaitingPlayers() {
    return gameState == GameState.waitingPlayers;
  }

  bool isWaitingSelectOrder() {
    return gameState == GameState.waitingHostSelectOrder;
  }

  bool isWaitingChooseToGuess() {
    return gameState == GameState.waitingPlayerChooseToGuess;
  }

  bool iChoosedToGuess() {
    return gameState == GameState.iChoosedToGuess;
  }

  bool isGameRunning() {
    return gameState == GameState.gameStarting;
  }

  void restartGame() {
    for (var player in players) {
      player.toGuess = null;
      player.image = null;
    }
    myPlayer.image = null;
    myPlayer.toGuess = null;
    isMyTurn = false;
    whosTurn = "";
    gameState = GameState.waitingPlayers;
  }
}
