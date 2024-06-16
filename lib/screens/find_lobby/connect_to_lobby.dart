import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/find_lobby/lobby_data.dart';
import 'package:quem_sou_eu/screens/game/game.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';
import 'package:quem_sou_eu/theme/input_decoration_theme.dart';

class ConnectToLobby extends StatefulWidget {
  const ConnectToLobby({super.key, required this.lobbyData});

  final LobbyData lobbyData;

  @override
  State<ConnectToLobby> createState() => _ConnectToLobbyState();
}

class _ConnectToLobbyState extends State<ConnectToLobby> {
  final _formKey = GlobalKey<FormState>();

  final nickController = TextEditingController();
  final passwordController = TextEditingController();
  bool esperandoResposta = false;

  String mensagemDeErro = "";

  void handleResponse(String data, socket) {
    final packet = GamePacket.fromString(data);
    socket.destroy();
    if (packet.response!.startsWith("SUCCESS")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Game(
                  player: Player(nickController.text, InternetAddress.anyIPv4),
                  port: 1234,
                  hostIP: InternetAddress.anyIPv4,
                  theme: widget.lobbyData.theme,
                  lobbyName: widget.lobbyData.name,
                  servidor: true,
                )),
      );
    } else {
      mensagemDeErro = data.split(";")[1];
    }
    setState(() {});
    esperandoResposta = false;
  }

  void connectToLobby(BuildContext context) async {
    setState(() {
      esperandoResposta = true;
    });
    try {
      final socket = await Server.connect();
      socket.listen(
          (data) => handleResponse(String.fromCharCodes(data), socket),
          onError: (error) =>
              mensagemDeErro = "Erro ao se comunicar com o servidor");
      GamePacket packet = GamePacket(
          fromHost: false,
          playerNick: nickController.text,
          type: PacketType.findLobby,
          playerIP: InternetAddress.anyIPv4,
          lobbyName: widget.lobbyData.name);
      if (widget.lobbyData.hasPassword)
        packet.password = passwordController.text;
      socket.write(packet.toString());
    } catch (e) {
      setState(() {
        esperandoResposta = false;
        mensagemDeErro = "Erro de comunicação";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Container(
            decoration: containerTheme(context).copyWith(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(160),
                  Theme.of(context).colorScheme.secondary.withAlpha(160),
                  Theme.of(context).colorScheme.tertiary.withAlpha(160),
                ])),
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                        child: Text(
                      "Entrar em ${widget.lobbyData.name}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                    SizedBox(
                      height: 70,
                    ),
                    TextFormField(
                      decoration: textFieldDecoration(hintText: "Seu nick"),
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
                    ),
                    widget.lobbyData.hasPassword
                        ? TextFormField(
                            decoration:
                                textFieldDecoration(hintText: "Password"),
                            style: Theme.of(context).textTheme.bodySmall,
                            controller: passwordController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty &&
                                      widget.lobbyData.hasPassword) {
                                return 'Por favor, insira o password';
                              }
                              return null;
                            },
                          )
                        : const SizedBox(height: 10),
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
                    esperandoResposta
                        ? const CircularProgressIndicator()
                        : Text(
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
        ),
      ),
    );
  }
}
