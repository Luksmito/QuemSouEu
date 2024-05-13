import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class SelectOrder extends StatefulWidget {
  SelectOrder({super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final RawDatagramSocket? socket;

  @override
  State<SelectOrder> createState() => _SelectOrderState();
}

/*ListView.builder(
            itemCount: widget.gameData.players.length + 1,
            itemBuilder: (_, int index) {
              return ListTile(
                  onTap: () => _toggle(index),
                  trailing: Checkbox(
                    value: playerSelected[index],
                    onChanged: (bool? x) => _toggle(index),
                  ),
                  title: Text(widget.gameData.players[index].nick));
            }),*/

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

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
       /* shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        insetPadding: const EdgeInsets.all(10),*/
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Escolha a ordem"),
            automaticallyImplyLeading: false,
          ),
          body: ListView.builder(
              itemCount: widget.gameData.players.length + 2,
              itemBuilder: (_, int index) {
                if (index < widget.gameData.players.length) {
                  return ListTile(
                      onTap: () => _toggle(index),
                      trailing: Checkbox(
                        value: playerSelected[index],
                        onChanged: (bool? x) => _toggle(index),
                      ),
                      title: Text(widget.gameData.players[index].nick));
                } else if (index == widget.gameData.players.length){
                  return Center(
                    child: Column(
                      children: List<Widget>.generate(playerList.length,
                          (index) => Text(playerList[index])),
                    ),
                  );
                } else {
                  return ElevatedButton(onPressed: () {
                    GamePacket packet = widget.gameData.myPlayer.createChangeStatePacket(GameState.waitingPlayerChooseToGuess);
                    packet.playerOrder = playerList;
                    widget.socket?.send(packet.toString().codeUnits, InternetAddress(Server.multicastAddress), widget.gameData.gamePort);
                    Navigator.pop(context);
                  }, child: Text("Pronto!"));
                }
              }),
        ));
  }
}
