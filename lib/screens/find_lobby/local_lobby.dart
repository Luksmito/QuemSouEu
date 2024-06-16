import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/game/game.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';
import 'package:quem_sou_eu/theme/input_decoration_theme.dart';

class LocalLobby extends StatefulWidget {
  @override
  State<LocalLobby> createState() => _LocalLobbyState();
}

class _LocalLobbyState extends State<LocalLobby> {
  final _formKey = GlobalKey<FormState>();

  final nickController = TextEditingController();

  final portController = TextEditingController();

  final ipController = TextEditingController();

  String mensagemDeErro = "";
  final spacer = const SizedBox(height: 10,);

   void connectToLobby(BuildContext context) async {
    setState(() {
      mensagemDeErro = "";
    });

    if (validateForm()) {
      int port = int.parse(portController.text);
      InternetAddress myIP = await Server.getIP();
      Player myPlayer = Player(nickController.text, myIP);
      InternetAddress hostIP = InternetAddress(ipController.text);
      GameData gameData = GameData(myPlayer, 6666, hostIP, "", "", false);

      try {
        RawDatagramSocket? socket = await createAndListenSocket(myIP, gameData);
        if (socket != null) {
          sendFindLobbyPacket(socket, myIP, hostIP, port);
          waitForResponse(context, gameData, myIP, hostIP, port);
        } else {
          print("Erro ao criar socket");
          return;
        }
      } catch (e) {
        throw Exception("Erro ao tentar se conectar");
      }
    }
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<RawDatagramSocket?> createAndListenSocket(
      InternetAddress myIP, GameData gameData) async {
    try {
      RawDatagramSocket? socket = await Server.start(6666, myIP);
      if (socket != null) {
        Server.startToListen(socket, gameData.processPacketLocal);
      }
      return socket;
    } catch (e) {
      print("Erro ao criar socket: $e");
      return null;
    }
  }

  void sendFindLobbyPacket(RawDatagramSocket socket, InternetAddress myIP,
      InternetAddress hostIP, int port) {
    GamePacket packet = GamePacket(
      playerIP: myIP,
      fromHost: false,
      playerNick: nickController.text,
      type: PacketType.findLobby,
    );
    socket.send(packet.toString().codeUnits, hostIP, port);
  }

  void waitForResponse(BuildContext context, GameData gameData,
      InternetAddress myIP, InternetAddress hostIP, int port) {
    int count = 0;
    mensagemDeErro = "Buscando...";
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (count < 5) {
        if (gameData.canConnect["changed"] == true) {
          timer.cancel();
          processResponse(context, gameData, myIP, hostIP, port);
        }
        count++;
      } else {
        setState(() {
          mensagemDeErro = "Partida não encontrada";
        });
        timer.cancel();
      }
    });
  }

  void processResponse(BuildContext context, GameData gameData,
      InternetAddress myIP, InternetAddress hostIP, int port) async {
    if (gameData.canConnect["canConnect"] == true) {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Game(
            player: Player(nickController.text, myIP),
            port: port,
            hostIP: hostIP,
            lobbyName: gameData.canConnect["lobbyName"],
            theme: gameData.canConnect["theme"],
            servidor: false,
          ),
        ),
      );
      print(resultado);
      if (resultado == "Host saiu") {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "O host saiu",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                content: Text("Você foi retirado da sala porque o host saiu.",
                    style: Theme.of(context).textTheme.bodySmall),
              );
            });
      }
    } else if (gameData.canConnect["nickUnavailable"] == true) {
      setState(() {
        mensagemDeErro = "Nick indisponível";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
        decoration: containerTheme(context).copyWith(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(160),
                  Theme.of(context).colorScheme.secondary.withAlpha(160),
                  Theme.of(context).colorScheme.tertiary.withAlpha(160),
                ])),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.bodySmall,
                  controller: nickController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nick';
                    } else if (value == "Escolha outro nick") {
                      return 'Nick já em uso';
                    }
                    return null;
                  },
                  decoration: textFieldDecoration(hintText: "Nick"),
                ),
                spacer,
                TextFormField(
                  style: Theme.of(context).textTheme.bodySmall,
                  controller: ipController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o ip';
                    } else if (InternetAddress.tryParse(value) == null) {
                      return 'Formto de ip inválido';
                    }
                    return null;
                  },
                   decoration: textFieldDecoration(hintText: "IP"),
                ),
                spacer,
                TextFormField(
                  style: Theme.of(context).textTheme.bodySmall,
                  controller: portController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a porta';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor, insira um número válido';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                   decoration: textFieldDecoration(hintText: "Porta"),
                ),
              
                spacer,
                Container(
                  decoration: buttonContainerTheme(context),
                  child: ElevatedButton(
                    onPressed: () => connectToLobby(context),
                    child: Text(
                      "Entrar",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mensagemDeErro,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.red),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
