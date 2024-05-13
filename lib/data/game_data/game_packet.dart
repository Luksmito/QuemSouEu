import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'dart:convert';

class GamePacket {
  final String playerNick;
  final bool fromHost;
  final PacketType type;

  List<String>? playerOrder;
  GameState? newGameState;
  List<String>? playersAlreadyInLobby;
  String? toGuess;
  String? image;
  String? response;


  GamePacket(
      {required this.fromHost,
      required this.playerNick,
      required this.type,
      this.newGameState,
      this.playersAlreadyInLobby,
      this.playerOrder,
      this.toGuess,
      this.image,
      this.response});

  factory GamePacket.fromMap(Map<String, dynamic> packet) {
    return GamePacket(
        fromHost: packet["fromHost"],
        playerNick: packet["playerNick"],
        type: packet["type"] is PacketType
            ? packet["type"]
            : packetTypeFromString(packet["type"]),
        playersAlreadyInLobby: packet["playersAlreadyInLobby"] != null
            ? List<String>.generate(packet["playersAlreadyInLobby"].length,
                (index) => packet["playersAlreadyInLobby"][index])
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
        response: packet["response"]
      );
  }

  factory GamePacket.fromString(String packet) {
    Map<String, dynamic> map = json.decode(packet);
    return GamePacket.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'playerNick': playerNick,
      'fromHost': fromHost,
      'type': type.toString(),
      'newGameState': newGameState.toString(),
      'playersAlreadyInLobby': playersAlreadyInLobby,
      'playerOrder': playerOrder,
      'toGuess': toGuess,
      'image': image,
      'response': response,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
