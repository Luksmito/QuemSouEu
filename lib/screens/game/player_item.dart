import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/screens/game/overlay.dart';

class PlayerItem extends StatefulWidget {
  const PlayerItem(
      {super.key,
      required this.player,
      required this.isMyPlayer,
      required this.gameData});

  final Player player;
  final bool isMyPlayer;
  final GameData gameData;

  @override
  State<PlayerItem> createState() => _PlayerItemState();
}

class _PlayerItemState extends State<PlayerItem> {
  bool isImageVisible = false;

  @override
  void initState() {
    super.initState();
  }

  final double cardHeight = 400;
  final double imageHeight = 300;
  bool _showOverlay = true;
  double opacityLevel = 0;

  double height(context) {
    return (MediaQuery.of(context).size.height / 2) - 40;
  }

  double width(context) {
    return (MediaQuery.of(context).size.width / 2) - 30;
  }

  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  Widget image() {
    if (!widget.isMyPlayer) {
      if (widget.player.image != null) {
        if (widget.player.image!.isNotEmpty) {
          return Container(
            constraints: BoxConstraints(
                maxHeight: (height(context) / 5) * 3, maxWidth: width(context)),
            child: Image.network(
              widget.player.image!,
              width: width(context),
              height: imageHeight,
              //fit: BoxFit.contain,
            ),
          );
        }
      }
    }
    return Container(
      constraints: BoxConstraints(
          maxHeight: (height(context) / 5) * 3, maxWidth: width(context)),
      child: Image.asset(
        "lib/assets/images/questionMark.png",
        width: width(context),
        height: imageHeight,
        //fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height(context),
      child: Card(
        color: widget.gameData.whosTurn == widget.player.nick
            ? Colors.blue
            : Colors.blueGrey,
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                image(),
                if (!widget.isMyPlayer)
                  Positioned.fill(
                      child: MyOverlay(
                    opacityLevel: opacityLevel,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.circular(20), // Define a borda curva
                        border: Border.all(
                          color: Colors.black, // Cor da borda
                          width: 2, // Largura da borda
                        ),
                      ),
                    ),
                  ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.player.nick),
                if (!widget.isMyPlayer)
                  IconButton(
                      onPressed: () {
                        _changeOpacity();
                        setState(() {
                          _showOverlay = !_showOverlay;
                        });
                      },
                      icon: Icon(_showOverlay
                          ? Icons.visibility
                          : Icons.visibility_off))
              ],
            ),
            Stack(
              children: [
                AnimatedOpacity(
                  opacity: 1 - opacityLevel,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                      child: Text(!widget.isMyPlayer
                          ? widget.player.getToGuess ?? ""
                          : "?")),
                ),
                /*if (!widget.isMyPlayer /*&& _showOverlay*/)
                  Positioned.fill(
                    child: MyOverlay(opacityLevel: opacityLevel),
                  ),*/
              ],
            )
          ],
        ),
      ),
    );
  }
}
