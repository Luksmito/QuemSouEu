import 'dart:convert';
import 'dart:io';

import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class GameDataCMD{
  final Player myPlayer;
  final List<Player> players = [];
  GameState gameState = GameState.waitingPlayers;
  late bool onLobby;
  final int gamePort;

  GameDataCMD(this.myPlayer, this.gamePort) {
    players.add(myPlayer);
    onLobby = myPlayer.isHost;
  }

  void addPlayer(Player player) {
    players.add(player);
  }

  void processNewPlayerPacket(GamePacket packet, RawDatagramSocket socket) {
    if (onLobby) {
        print("Adicionando player ${packet.playerNick}");
        addPlayer(Player(packet.playerNick));
        if (myPlayer.isHost) {
          print("Host enviando para o novo player o pacote com os players da sala");
          GamePacket gamePacket = GamePacket(
              fromHost: true,
              playerNick: myPlayer.nick,
              type: PacketType.sendPlayersAlreadyInLobby,
              playersAlreadyInLobby: List<String>.generate(players.length, (index) => players[index].nick)
          );
          print(gamePacket.toString());
          socket.send(json.encode(gamePacket.toJson()).codeUnits,
              InternetAddress(Server.multicastAddress), gamePort);
        }
      }
  }

  void processPacket(String packet, RawDatagramSocket socket) {
    print("Packet Received $packet");
    GamePacket newPacket = GamePacket.fromString(packet);
    if (newPacket.playerNick == myPlayer.nick) {
        print("Pacote recebido de mim mesmo");
        return;
    }
    switch (newPacket.type) {
      case PacketType.newPlayer:
        if (isWaitingPlayers()) {
          processNewPlayerPacket(newPacket, socket);
        }
        break;
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
        }
        break;
      default:
        break;
    }
  }

  void printPlayers() {
    for (Player player in players) {
      print("Nick: ${player.nick}");
    }
  }

   bool isWaitingPlayers() {
    return gameState == GameState.waitingPlayers;
  }
}
