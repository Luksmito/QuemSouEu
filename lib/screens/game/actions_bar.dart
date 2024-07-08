import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/game_states.dart';
import 'package:quem_sou_eu/screens/game/chat.dart';
import 'package:quem_sou_eu/screens/utils/utils.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';
import 'package:quem_sou_eu/theme/square_button_theme.dart';

class ActionsBar extends StatefulWidget {
  const ActionsBar({super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final dynamic socket;

  @override
  State<ActionsBar> createState() => _ActionsBarState();
}

class _ActionsBarState extends State<ActionsBar> {
  final List<Widget> linhaDeBaixo = [];

  bool chatToggle = false;
  double bottomPadding = 0;

  @override
  void initState() {
    super.initState();
  }

  void setPadding() {
    setState(() {
      bottomPadding = bottomPadding == 0 ? 230 : 0;
    });
  }

  void restartGame(context) async {
    final result = await confirmationDialog(
        "Reiniciar o jogo", "Deseja reiniciar o jogo?", context);
    if (!result!) return;
    GamePacket packet = widget.gameData.myPlayer.createRestartGamePacket();
    if (widget.gameData.myPlayer.isHost && !widget.gameData.isServer) {
      widget.gameData.setGameState = GameState.waitingPlayers;
      widget.gameData.sendPacketToAllPlayers(widget.socket!, packet);
      widget.gameData.restartGame();
    } else {
      packet.lobbyName = widget.gameData.lobbyName;
      widget.gameData.restartGame();
      widget.socket.write(packet.toString());
    }
  }

  void changeToSelectOrderState() {
    /*if (widget.gameData.players.length == 1) {
      return;
    }*/
    GamePacket packet = widget.gameData.myPlayer
        .createChangeStatePacket(GameState.waitingHostSelectOrder);
    if (widget.gameData.myPlayer.isHost) {
      widget.gameData.setGameState = GameState.waitingHostSelectOrder;
      widget.gameData.sendPacketToAllPlayers(widget.socket!, packet);
    }
  }

  void sendPacketPassTurn() {
    GamePacket packet = widget.gameData.myPlayer.createPassTurnPacket();
    if (widget.gameData.myPlayer.isHost && !widget.gameData.isServer) {
      widget.gameData.sendPacketToAllPlayers(widget.socket!, packet);
    } else {
      if (widget.gameData.isServer) {
        packet.lobbyName = widget.gameData.lobbyName;
        widget.socket.write(packet.toString());
      } else {
        widget.socket?.send(packet.toString().codeUnits, widget.gameData.hostIP,
            widget.gameData.gamePort);
      }
    }
    widget.gameData.passTurn();
  }

  void buildBar(BuildContext context) {
    linhaDeBaixo.clear();
    if (widget.gameData.myPlayer.isHost) {
      if (widget.gameData.isWaitingPlayers()) {
        linhaDeBaixo.add(Flexible(
            child: Container(
          decoration: buttonContainerTheme(context),
          child: ElevatedButton(
              style: squareButtonTheme(),
              onPressed: changeToSelectOrderState,
              child: Text("Selecionar ordem",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary))),
        )));
        if (!widget.gameData.isServer) {
          linhaDeBaixo.add(Text(
              "Ip: ${widget.gameData.hostIP.address}\nPorta: ${widget.gameData.gamePort}",
              style: Theme.of(context).textTheme.bodySmall));
        }
      }
    } else {
      if (widget.gameData.isWaitingPlayers()) {
        linhaDeBaixo.add(Text(
          "Esperando jogadores...",
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      } else if (widget.gameData.isWaitingSelectOrder()) {
        linhaDeBaixo.clear();
        linhaDeBaixo.add(Text(
          "Esperando host escolher a ordem...",
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }
    }
    if (widget.gameData.isWaitingChooseToGuess() ||
        widget.gameData.iChoosedToGuess()) {
      linhaDeBaixo.add(const Text("Esperando players..."));
    } else if (widget.gameData.isGameRunning()) {
      linhaDeBaixo.clear();
      if (widget.gameData.isMyTurn) {
        linhaDeBaixo.add(Flexible(
            child: Container(
          decoration: buttonContainerTheme(context),
          child: ElevatedButton(
              style: squareButtonTheme(),
              onPressed: sendPacketPassTurn,
              child: Text("Passar vez",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary))),
        )));
      } else {
        linhaDeBaixo.add(Text("Vez de ${widget.gameData.whosTurn}"));
      }
      if (widget.gameData.myPlayer.isHost) {
        linhaDeBaixo.add(Flexible(
            child: Container(
          decoration: buttonContainerTheme(context),
          child: ElevatedButton(
              style: squareButtonTheme(),
              onPressed: () => restartGame(context),
              child: Expanded(
                child: Text("Reiniciar jogo",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary)),
              )),
        )));
      }
    }
    linhaDeBaixo.add(
      Flexible(
          child: Container(
        decoration: buttonContainerTheme(context),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () {
            widget.gameData.resetReadMessages();
            setState(() {
              chatToggle = !chatToggle;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chat),
              Text(
                  widget.gameData.notReadMessages != 0 && !chatToggle
                      ? "${widget.gameData.notReadMessages}"
                      : "",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.red)),
            ],
          ),
        ),
      )),
    );
  }



  @override
  Widget build(BuildContext context) {
    buildBar(context);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Chat(
            gameData: widget.gameData,
            toggle: chatToggle,
            socket: widget.socket,
            callbackPaddingKeyboard: setPadding
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: linhaDeBaixo,
          )
        ],
      ),
    );
  }
}
