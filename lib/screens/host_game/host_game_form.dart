import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/host.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/find_lobby/button_select_server.dart';
import 'package:quem_sou_eu/screens/game/game.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';
import 'package:quem_sou_eu/theme/input_decoration_theme.dart';

class HostGameForm extends StatefulWidget {
  const HostGameForm({super.key});

  @override
  State<HostGameForm> createState() => _HostGameFormState();
}

class _HostGameFormState extends State<HostGameForm> {
  final _formKey = GlobalKey<FormState>();
  final nickController = TextEditingController();
  final portController = TextEditingController();
  final lobbyNameController = TextEditingController();
  final themeController = TextEditingController();
  final passwordController = TextEditingController();

  bool servidor = true;
  bool password = false;
  final spacer = const SizedBox(
    height: 15,
  );
  String mensagemDeErro = "";

  String? validatorForWords(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validatorForPassword(String? value) {
    if (value == null || value.isEmpty && password) {
      return 'Insira a senha';
    }
    return null;
  }

  String? validatorForNumber(String? value) {
    if (servidor) return null;
    int? number = value != null ? int.parse(value) : null;
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    } else if (number == null || number < 1000 || number > 63000) {
      return 'Necessário que seja um numero entre 2000 e 63000';
    }
    return null;
  }

  void setServerSource() {
    servidor = !servidor;
    setState(() {});
  }

  void handleResponse(data, socket) {
    data = String.fromCharCodes(data);
    if (data.startsWith("SUCCESS")) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Game(
                player: Host(nickController.text, InternetAddress.anyIPv4),
                port: !servidor ? int.parse(portController.text) : 1234,
                hostIP: InternetAddress.anyIPv4,
                theme: themeController.text,
                lobbyName: lobbyNameController.text,
                servidor: true,
              )),
      );
    } else {
      final response = data.split(';');
      setState(() {
        mensagemDeErro = response[1];
      });
    }
  }

  void handleCreateLobby() async {
    mensagemDeErro = "";
    Socket socket = await Server.connect();
    socket.listen((data) => handleResponse(data, socket),
        onDone: () => socket.destroy(),
        onError: (error) {
          print("ERRO!");
          socket.destroy();
        });
    final pacote = GamePacket(
        fromHost: true,
        playerNick: nickController.text,
        type: PacketType.createLobby,
        playerIP: InternetAddress("0.0.0.0"),
        lobbyName: lobbyNameController.text,
        theme: themeController.text);
    if (password) pacote.password = passwordController.text;
    socket.write(pacote);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ButtonSelectServer(callback: setServerSource, servidor: servidor),
            spacer,
            TextFormField(
              validator: validatorForWords,
              controller: lobbyNameController,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: textFieldDecoration(hintText: "Nome da sala"),
            ),
            spacer,
            TextFormField(
              controller: nickController,
              validator: validatorForWords,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: textFieldDecoration(hintText: "Seu nick"),
            ),
            spacer,
            TextFormField(
              controller: themeController,
              validator: validatorForWords,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: textFieldDecoration(hintText: "Tema"),
            ),
            spacer,
            !servidor
                ? TextFormField(
                    controller: portController,
                    validator: validatorForNumber,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: textFieldDecoration(hintText: "Porta"),
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Senha",
                              style: Theme.of(context).textTheme.bodySmall),
                          Checkbox(
                              value: password,
                              onChanged: (value) {
                                setState(() {
                                  password = !password;
                                });
                              }),
                        ],
                      ),
                      TextFormField(
                        enabled: password,
                        controller: passwordController,
                        validator: validatorForPassword,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: textFieldDecoration(hintText: "Senha"),
                      )
                    ],
                  ),
            spacer,
            Container(
                decoration: buttonContainerTheme(context),
              child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (servidor) {
                        handleCreateLobby();
                      } else {
                        InternetAddress ip = await Server.getIP();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Game(
                                  player: Host(nickController.text, ip),
                                  port: !servidor
                                      ? int.parse(portController.text)
                                      : 1234,
                                  hostIP: ip,
                                  theme: themeController.text,
                                  lobbyName: lobbyNameController.text,
                                  servidor: servidor)),
                        );
                      }
                    }
                  },
                  child: Text("Criar", style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary))),
            ),
            spacer,
            Text(
              mensagemDeErro,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.red),
            )
          ],
        ));
  }
}
