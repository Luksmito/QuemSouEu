
import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';

class SelectOrder extends StatefulWidget {
  SelectOrder({super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final dynamic socket;

  @override
  State<SelectOrder> createState() => _SelectOrderState();
}

class _SelectOrderState extends State<SelectOrder> {
  List<String> playerList = [];
  List<bool> playerSelected = [];
  List<Widget> listView = [];

  @override
  void initState() {
    super.initState();
    playerSelected =
        List.generate(widget.gameData.players.length, (index) => false);
  }

  void _toggle(int index) {
    setState(() {
      playerSelected[index] = !playerSelected[index];
      if (playerList.contains(widget.gameData.players[index].nick)) {
        playerList.remove(widget.gameData.players[index].nick);
      } else {
        playerList.add(widget.gameData.players[index].nick);
      }
    });
  }

  bool allPlayersSelected() {
    return !playerSelected.contains(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog.fullscreen(
          /* shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          insetPadding: const EdgeInsets.all(10),*/
          child: Scaffold(
        bottomNavigationBar: Container(
                decoration: buttonContainerTheme(context),
              child: ElevatedButton(
            onPressed: () {
              if (!allPlayersSelected()) return;
              GamePacket packet = widget.gameData.myPlayer
                  .createChangeStatePacket(GameState.waitingPlayerChooseToGuess);
              packet.playerOrder = playerList;
              widget.gameData.setGameState = GameState.waitingPlayerChooseToGuess;
              if (widget.gameData.isServer) {
                packet.lobbyName = widget.gameData.lobbyName;
                widget.socket.write(packet.toString());
              } else {
                widget.gameData.sendPacketToAllPlayers(widget.socket!, packet);
              }
              widget.gameData.setPlayerOrder(playerList);
              Navigator.pop(context);
            },
            child: const Text("Pronto!"))),
        appBar: AppBar(
          title: const Text("Escolha a ordem"),
          automaticallyImplyLeading: false,
        ),
        body: ListView.builder(
            itemCount: widget.gameData.players.length + 1,
            itemBuilder: (_, int index) {
              if (index < widget.gameData.players.length) {
                return ListTile(
                    onTap: () => _toggle(index),
                    trailing: Checkbox(
                      value: playerSelected[index],
                      onChanged: (bool? x) => _toggle(index),
                    ),
                    title: Text(widget.gameData.players[index].nick));
              } else {
                return Center(
                  child: Column(
                    children: List<Widget>.generate(
                        playerList.length, (index) => Text(playerList[index])),
                  ),
                );
              }
            }),
      )),
    );
  }
}
