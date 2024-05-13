import 'dart:io';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_data.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/game/game.dart';

class FindLobby extends StatefulWidget {
  const FindLobby({Key? key}) : super(key: key);

  @override
  State<FindLobby> createState() => _FindLobbyState();
}

class _FindLobbyState extends State<FindLobby> {
  final _formKey = GlobalKey<FormState>();

  final nickController = TextEditingController();

  final portController = TextEditingController();

  String mensagemDeErro = "";

  @override
  void initState() {
    if (Platform.isAndroid) {
      print("Pegando multicast");
      MulticastLock().acquire();
    }
    
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      print("Soltando multicast");
      MulticastLock().release();
    }
    super.dispose();
  }
  

  void connectToLobby(BuildContext context) async {
    mensagemDeErro = "";
    if (_formKey.currentState!.validate()) {
      int port = int.parse(portController.text);
      Player myPlayer = Player(nickController.text);
      GameData gameData = GameData(myPlayer, port);
      try {
        RawDatagramSocket? socket = await Server.start(port);
        if (socket != null) {
          Server.startToListen(socket, gameData.processPacket);
          GamePacket packet = GamePacket(
            fromHost: false,
            playerNick: myPlayer.nick,
            type: PacketType.findLobby
          );
          socket.send(packet.toString().codeUnits, InternetAddress(Server.multicastAddress), port); 
        } else {
          return;
        }
        await Future.delayed(const Duration(seconds: 5), () {
          if (gameData.canConnect["changed"] == true) {
            print("RESPOSTA OUVIDA ${gameData.canConnect["nickUnavailable"]}");
            if (gameData.canConnect["canConnect"] == true) {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Game(
                                player: Player(nickController.text),
                                port: int.parse(portController.text)
                              )),
                    );
            } else if (gameData.canConnect["nickUnavailable"] == true) {
              setState(() {
                mensagemDeErro = "Nick indisponível";
              });
            }
          } else {   
            setState(() {
              mensagemDeErro = "Partida não encontrada";
            });
          }
        });
        
      } catch (e) {
        throw Exception("Erro ao tentar se conectar");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Buscar jogo",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
            decoration: BoxDecoration(border: Border.all()),
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
                      decoration: InputDecoration(
                        labelText: "Seu nick",
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
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
                      decoration: InputDecoration(
                        labelText: "Porta",
                        labelStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => connectToLobby(context),
                      child: Text(
                        "Entrar",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(mensagemDeErro, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red),)
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
