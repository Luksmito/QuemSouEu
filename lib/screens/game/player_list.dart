import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/screens/game/player_item.dart';

class PlayerList extends StatelessWidget {
  PlayerList({super.key, required this.gameData});

  final GameData gameData;


  @override
  Widget build(BuildContext context) {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 10,
      childAspectRatio: 0.57,
      crossAxisCount: 2,
      children: List.generate(gameData.players.length, (index) {
        return PlayerItem(
                  gameData: gameData,
                  player: gameData.players[index],
                  isMyPlayer: gameData.players[index].nick == gameData.myPlayer.nick,
                );
      }),
    );
  }
}
