import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class GameData with ChangeNotifier {
  final Player myPlayer;
  final List<Player> players = [];
  GameState gameState = GameState.waitingPlayers;
  late bool onLobby;
  final int gamePort;
  bool isMyTurn = false;
  String whosTurn = ""; 

  Map<String, bool> canConnect = {
    "canConnect": false,
    "nickUnavailable": false,
    "changed": false
  };

  GameData(this.myPlayer, this.gamePort) {
    players.add(myPlayer);
    onLobby = myPlayer.isHost;
  }

  int findIndexNextPlayer(String nick) {
    for (int i = 0; i < players.length; i++) {
      if (myPlayer.nick == players[i].nick) {
        return (i+1) % players.length;
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

  void processNewPlayerPacket(GamePacket packet, RawDatagramSocket socket) {
    if (onLobby) {
      print("Adicionando player ${packet.playerNick}");
      addPlayer(Player(packet.playerNick));
      if (myPlayer.isHost) {
        print(
            "Host enviando para o novo player o pacote com os players da sala");
        GamePacket gamePacket = GamePacket(
            fromHost: true,
            playerNick: myPlayer.nick,
            type: PacketType.sendPlayersAlreadyInLobby,
            playersAlreadyInLobby: List<String>.generate(
                players.length, (index) => players[index].nick));
        print(gamePacket.toString());
        socket.send(json.encode(gamePacket.toJson()).codeUnits,
            InternetAddress(Server.multicastAddress), gamePort);
      }
    }
  }

  void setToGuess(newPacket) {
    for (var player in players) {
      if (player.nick == newPacket.playerNick) {
        player.toGuess = newPacket.toGuess;
        player.image = newPacket.image;
        break;
      }
    }
    ;
  }

  bool isAllPlayersToGuessSetted() {
    for (var player in players) {
      if (player.toGuess == null) {
        return false;
      }
    }
    return true;
  }

  void processPacket(String packet, RawDatagramSocket socket) {
    print("Packet Received $packet");
    GamePacket newPacket = GamePacket.fromString(packet);
    switch (newPacket.type) {
      case PacketType.newPlayer:
        if (isWaitingPlayers() && newPacket.playerNick != myPlayer.nick) {
          processNewPlayerPacket(newPacket, socket);
        }
        break;
      case PacketType.findLobby:
        if (myPlayer.isHost) {
          final nicks = List.generate(players.length, (index) => players[index].nick);
          GamePacket response = GamePacket(
            fromHost: true,
            playerNick: myPlayer.nick,
            type: PacketType.findLobbyResponse,
          );
          response.response = nicks.contains(newPacket.playerNick) ? "nick indisponivel" : "ok";
          socket.send(response.toString().codeUnits, InternetAddress(Server.multicastAddress), gamePort);
        }
      case PacketType.findLobbyResponse:
        if (!onLobby && newPacket.fromHost) {
          canConnect["changed"] = true;
          if (newPacket.response == "ok") {
            canConnect["canConnect"] = true;
            
          } else if (newPacket.response == "nick indisponivel") {
            canConnect["nickUnavailable"] = true;
          }
          socket.close();
        }
      case PacketType.sendPlayersAlreadyInLobby:
        if (!onLobby) {
          print("Recebendo players já cadastrados");
          for (int i = 0; i < newPacket.playersAlreadyInLobby!.length; i++) {
            String nick = newPacket.playersAlreadyInLobby![i];
            if (nick != myPlayer.nick) {
              print("Player Recebido $nick");
              addPlayer(Player(nick));
            }
          }
          onLobby = true;
        }
        break;
      case PacketType.gameStateChange:
        gameState = newPacket.newGameState!;
        if (gameState == GameState.waitingPlayerChooseToGuess) {
          players.clear();
          for (var player in newPacket.playerOrder!) {
            players.add(Player(player));
          }
        } else if (gameState == GameState.gameStarting) {
          whosTurn = players[0].nick;
          isMyTurn = whosTurn == myPlayer.nick;
        }
        break;
      case PacketType.setToGuess:
        setToGuess(newPacket);
        if (myPlayer.isHost) {
          if (isAllPlayersToGuessSetted()) {
            GamePacket sendPacket = GamePacket(
              fromHost: true, 
              playerNick: myPlayer.nick, 
              type: PacketType.gameStateChange,
              newGameState: GameState.gameStarting
            );
            socket.send(sendPacket.toString().codeUnits, InternetAddress(Server.multicastAddress), gamePort);
            whosTurn = players[0].nick;
            isMyTurn = whosTurn == myPlayer.nick;
          }
        }
      return;
      case PacketType.passTurn:
        int index = (players.indexWhere((player) => player.nick == whosTurn) + 1) % players.length;
        whosTurn = players[index].nick;
        isMyTurn = whosTurn == myPlayer.nick;
      default:
        break;
    }
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
}
