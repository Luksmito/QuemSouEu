import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';

class Chat extends StatefulWidget {
  Chat({
    super.key,
    required this.gameData,
    required this.toggle,
    required this.socket,
    required this.callbackPaddingKeyboard
  });

  final GameData gameData;
  final bool toggle;
  final dynamic socket;
  final VoidCallback callbackPaddingKeyboard;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String chatMessages = "";
  final messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    widget.callbackPaddingKeyboard();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (messageController.text.isEmpty) return;
    String message =
        "${widget.gameData.myPlayer.nick}: ${messageController.text}";
    widget.gameData.addMessage(message);
    GamePacket messagePacket =
        widget.gameData.myPlayer.createMessagePacket(message);
    if (widget.gameData.myPlayer.isHost && !widget.gameData.isServer) {
      widget.gameData.sendPacketToAllPlayers(widget.socket, messagePacket);
    } else {
      if (widget.gameData.isServer) {
        messagePacket.lobbyName = widget.gameData.lobbyName;
        widget.socket.write(messagePacket.toString());
      } else {
        widget.socket?.send(messagePacket.toString().codeUnits,
            widget.gameData.hostIP, widget.gameData.gamePort);
      }
    }
    messageController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
          border: Border.all(),
          color: Theme.of(context).colorScheme.primary.withAlpha(128),
          borderRadius: BorderRadius.circular(10)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: widget.toggle ? 200 : 0,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(widget.gameData.messages.length,
                    (index) {
                  final message = widget.gameData.messages[index].split(":");
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.gameData.messages[index],
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: message[0] == widget.gameData.myPlayer.nick
                              ? Colors.red
                              : Colors.black),
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: messageController,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: InputDecoration(
                      hintText: "Mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
