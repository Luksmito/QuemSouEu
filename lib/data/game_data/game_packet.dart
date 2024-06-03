import 'dart:io';

import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'dart:convert';

class GamePacket {
  final String playerNick;
  final bool fromHost;
  final PacketType type;
  final InternetAddress playerIP;

  List<String>? playerOrder;
  GameState? newGameState;
  List<Map<String,dynamic>>? playersAlreadyInLobby;
  String? toGuess;
  String? image;
  String? response;
  String? newPlayerNick;
  String? lobbyName;
  String? theme;

  GamePacket(
      {required this.fromHost,
      required this.playerNick,
      required this.type,
      required this.playerIP,
      this.newGameState,
      this.playersAlreadyInLobby,
      this.playerOrder,
      this.toGuess,
      this.image,
      this.response,
      this.newPlayerNick,
      this.lobbyName,
      this.theme
      });

  factory GamePacket.fromMap(Map<String, dynamic> packet) {
    return GamePacket(
        fromHost: packet["fromHost"],
        playerNick: packet["playerNick"],
        playerIP: InternetAddress(packet["playerIP"]),
        newPlayerNick: packet["newPlayerNick"],
        type: packet["type"] is PacketType
            ? packet["type"]
            : packetTypeFromString(packet["type"]),
        playersAlreadyInLobby: packet["playersAlreadyInLobby"] != null
            ? List<Map<String,String>>.generate(packet["playersAlreadyInLobby"].length,
                (index) => {
                  "nick": packet["playersAlreadyInLobby"][index]["nick"].toString(),
                  "ip": packet["playersAlreadyInLobby"][index]["ip"].toString()
                  })
            : null,
        newGameState: packet["newGameState"] is GameState
            ? packet["newGameState"]
            : gameStateFromString(packet["newGameState"]),
        playerOrder: packet["playerOrder"] != null
            ? List<String>.generate(packet["playerOrder"].length,
                (index) => packet["playerOrder"][index])
            : null,
        toGuess: packet["toGuess"],
        image: packet["image"],
        response: packet["response"],
        lobbyName: packet["lobbyName"],
        theme: packet["theme"]
      );
  }

  factory GamePacket.fromString(String packet) {
    Map<String, dynamic> map = json.decode(packet);
    print("AQUI");
    return GamePacket.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'playerNick': playerNick,
      'fromHost': fromHost,
      'playerIP': playerIP.address,
      'type': type.toString(),
      'newGameState': newGameState.toString(),
      'playersAlreadyInLobby': playersAlreadyInLobby,
      'playerOrder': playerOrder,
      'toGuess': toGuess,
      'image': image,
      'response': response,
      'newPlayerNick': newPlayerNick,
      'lobbyName': lobbyName,
      'theme': theme
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
