
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';

class Player {
  final String nick;
  String? image;
  String? toGuess; 


  Player(this.nick);

  set setImage(String image) => this.image = image;
  set setToGuess(String toGuess) => this.toGuess = toGuess;
  String? get getImage => image;
  String? get getToGuess => toGuess;
  bool get isHost => false;

  GamePacket createNewPlayerPacket() {
    GamePacket packet = GamePacket(
      fromHost: isHost, 
      playerNick: nick, 
      type: PacketType.newPlayer
    );
    return packet;
  }

  GamePacket createChangeStatePacket(GameState newGameState){
    return GamePacket(
      fromHost: isHost, 
      playerNick: nick, 
      type: PacketType.gameStateChange,
      newGameState: newGameState
    );
  }

  GamePacket createSetToGuessPacket(Map<String,String> toGuess) {
    return GamePacket(
      fromHost: isHost,
      playerNick: toGuess["nick"]!,
      type: PacketType.setToGuess,
      toGuess: toGuess["toGuess"],
      image: toGuess["image"]
    );
  }

  GamePacket createPassTurnPacket() {
    return GamePacket(
      fromHost: isHost,
      playerNick: nick,
      type: PacketType.passTurn,
    );
  }

}