import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:http/http.dart' as http;
import 'package:quem_sou_eu/screens/game/image_to_guess.dart';
import 'package:quem_sou_eu/screens/utils/utils.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';

class SelectToGuess extends StatefulWidget {
  const SelectToGuess(
      {super.key, required this.gameData, required this.socket});

  final GameData gameData;
  final dynamic socket;

  @override
  State<SelectToGuess> createState() => _SelectToGuessState();
}

class _SelectToGuessState extends State<SelectToGuess> {
  int nextPlayerIndex = 0;
  final TextEditingController nomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Widget> widgetList = [];
  List<String> images = [];
  String hostImages = 'https://serpapi.com/search.json';
  String apiKey =
      "a0abc8c70cff4943c6998d8becfc561aabf6ce028af85253c8e1c7b4d62dd9c6";
  bool _isLoading = false;
  int indexImageSelected = -1;


  @override
  void initState() {
    super.initState();
    nextPlayerIndex = findIndexNextPlayer();
  }

  int findIndexNextPlayer() {
    for (int i = 0; i < widget.gameData.players.length; i++) {
      if (widget.gameData.myPlayer.nick == widget.gameData.players[i].nick) {
        return (i + 1) % widget.gameData.players.length;
      }
    }
    return 0;
  }

  void setImageSelectedIndex(int index) {
    setState(() {
      indexImageSelected = index;
    });
  }

  void setImages(Map<String, dynamic> map) {
    setState(() {
      for (int i = 0; i < 4; i++) {
        images.add(map["images_results"][i]["original"]);
      }
      _isLoading = false;
    });
  }

  void choosed() async {
    if (nomeController.text.isNotEmpty) {
      if (indexImageSelected == -1) {
        final result = await confirmationDialog(
            "Não deseja escolher uma imagem?",
            "Clique em sim para prosseguir sem escolher uma imagem",
            context);
        if (!result!) {
          return;
        }
      }
      if (!context.mounted) return;
      final results = {
        "nick": widget.gameData.players[nextPlayerIndex].nick,
        "toGuess": nomeController.text,
        "image": indexImageSelected != -1 ? images[indexImageSelected] : ""
      };
      Navigator.of(context).pop(results);
    }
  }

  void searchImages() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse(
        '$hostImages?q=${nomeController.text}&engine=google_images&ijn=0&num=8&api_key=$apiKey');
    try {
      http.get(url).then(
        (response) {
          if (response.statusCode != 200) {
            throw Exception("erro ao buscar imagens");
          } else {
            Map<String, dynamic> map = json.decode(response.body);
            print("Encontrado");
            setImages(map);
          }
        },
      );
    } catch (e) {
      throw Exception("erro ao buscar imagens");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
            bottomNavigationBar:
             Container(
                decoration: buttonContainerTheme(context),
              child: ElevatedButton(
                onPressed: choosed,
                child: Text(
                  "Escolhido",
                  style: Theme.of(context).textTheme.bodySmall,
                ))),
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "${widget.gameData.players[nextPlayerIndex].nick}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FocusScope(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextField(
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                            labelText:
                                "O que ${widget.gameData.players[nextPlayerIndex].nick} deve adivinhar?",
                            labelStyle: Theme.of(context).textTheme.bodyMedium),
                        controller: nomeController,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                    decoration: buttonContainerTheme(context),
                  child: ElevatedButton(
                              onPressed: searchImages,
                              child: Text(
                                "Buscar imagem",
                                style: Theme.of(context).textTheme.bodySmall,
                              ))),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Flexible(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : images.isEmpty
                                ? Expanded(
                                    child: Text('Busque uma imagem!', style: Theme.of(context).textTheme.bodyMedium,))
                                : Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: ImagesToGuess(
                                        images: images,
                                        callBackFunction: setImageSelectedIndex,
                                        indexImageSelected: indexImageSelected),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      );
  }
}
