import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/server/server.dart';
import 'package:quem_sou_eu/screens/find_lobby/lobby_data.dart';
import 'package:quem_sou_eu/screens/find_lobby/lobby_item.dart';
import 'package:quem_sou_eu/theme/input_decoration_theme.dart';

class ServerLobby extends StatefulWidget {
  const ServerLobby({super.key});

  @override
  State<ServerLobby> createState() => _ServerLobbyState();
}

class _ServerLobbyState extends State<ServerLobby> {
  final List<LobbyData> lobbys = [];
  int searchComplete = 0;
  final searchController = TextEditingController();
  late Socket socket;

  void setSearchComplete() {
    if (mounted) {
      searchComplete = 1;
      setState(() {});
    }
  }

  void getLobbys({String? search}) async {
    searchComplete = 0;
    lobbys.clear();
    try {
      socket = await Server.connect();
      socket.listen((data) {
        final message = utf8.decode(data);
        if (message.startsWith("LOBBY_LIST")) {
          final args = message.split(";");
          final list = args[1];
          final decoded = jsonDecode(list);
          List<String> lobbyList = List<String>.from(decoded);
          for (var lobbyData in lobbyList) {
            var data = lobbyData.split("/");
            lobbys.add(LobbyData(
                data[0], data[1], bool.parse(data[2]), int.parse(data[3])));
          }
          setSearchComplete();
        } else {
          setState(() {
            searchComplete = -1;
          });
        }
      }, onDone: () {
        socket.destroy();
      }, onError: (error) {
        print("Erro: $error");
        socket.destroy();
      });

      final pacote = GamePacket(
        fromHost: false,
        playerNick: "teste",
        type: PacketType.listLobbys,
        playerIP: InternetAddress("0.0.0.0"),
      );
      if (search != null) pacote.lobbyName = search;
      socket.write(pacote.toString());
    } on Exception {
      searchComplete = -1;
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getLobbys();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> buildList() {
    List<Widget> list = [];
    for (var lobby in lobbys) {
      list.add(LobbyItem(lobby: lobby));
      list.add(const SizedBox(
        height: 10,
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          Flexible(
            child: TextField(
              decoration: textFieldDecoration(hintText: "Pesquisar sala"),
              style: Theme.of(context).textTheme.bodySmall,
              controller: searchController,
            ),
          ),
          IconButton(
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  getLobbys(search: searchController.text);
                } else {
                  getLobbys();
                }
              },
              icon: const Icon(Icons.search)),
        ],
      ),
      const SizedBox(
        height: 15,
      ),
      searchComplete == 0
          ? const Center(child: CircularProgressIndicator())
          : searchComplete == 1
              ? Column(
                  children: buildList(),
                )
              : const Text("Sala não encontrada")
    ]);
  }
}
