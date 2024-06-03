import 'dart:convert';
import 'dart:io';

import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class GameDataCMD {
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

  void sendPacketToAllPlayers(RawDatagramSocket socket, GamePacket packet) {
    for (var player in players) {
      print("Enviando para $player");
      if (player.nick != myPlayer.nick) {
        socket.send(packet.toString().codeUnits, player.myIP, gamePort);
      }
    }
  }

  List<Map<String,String>> generatePlayersInLobby() {
    return List<Map<String, String>>.generate(
                players.length,
                (index) => {
                      "nick": players[index].nick,
                      "ip": players[index].myIP.address
                    });
  }

  void processNewPlayerPacket(GamePacket packet, RawDatagramSocket socket) {
    if (onLobby) {
      print("Adicionando player ${packet.playerNick}");
      addPlayer(Player(packet.playerNick, packet.playerIP));
      if (myPlayer.isHost) {
        print(
            "Host enviando para o novo player o pacote com os players da sala");
        GamePacket gamePacket = GamePacket(
            fromHost: true,
            playerNick: myPlayer.nick,
            playerIP: myPlayer.myIP,
            type: PacketType.sendPlayersAlreadyInLobby,
            playersAlreadyInLobby: generatePlayersInLobby());

        print(gamePacket.toString());
        socket.send(gamePacket.toString().codeUnits, packet.playerIP,
            gamePort);
        gamePacket = GamePacket(
          fromHost: true,
          playerNick: packet.playerNick,
          playerIP: packet.playerIP,
          type: PacketType.newPlayer,
        );
        sendPacketToAllPlayers(socket, packet);
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
      print("Cheguei aqui");
        if (!onLobby) {
          print("Recebendo players já cadastrados");
          for (int i = 0; i < newPacket.playersAlreadyInLobby!.length; i++) {
            var nick =  newPacket.playersAlreadyInLobby![i]["nick"]!;
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
        /*if (gameState == GameState.waitingPlayerChooseToGuess) {
          players.clear();
          for (var player in newPacket.playerOrder!) {
            players.add(Player(player));
          }
        }*/
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
