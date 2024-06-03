import 'dart:io';
import 'dart:convert';

import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';
import 'package:quem_sou_eu/data/player/host.dart';
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';

import 'game_data_cmd.dart';

const portaMulticast = 6464;

void writeToFile(String content) {
  // Abra o arquivo em modo de escrita
    File file = File("./testeFile");

    // Escreva o conteúdo no arquivo
    file.writeAsStringSync(content);

}

String convertGamePacketToJson(GamePacket gamePacket) {
  return jsonEncode(gamePacket.toJson());
}

void main() async {
  InternetAddress myIP = InternetAddress("2804:214:87f3:3132:17ce:d1ba:a6d:4ebc%8");
  
  print("Player ou host: ");
  String? playerOuHost = stdin.readLineSync();
  print("Nome: ");
  String? nome = stdin.readLineSync();
  var player = playerOuHost == "player" ? Player(nome!, InternetAddress("2804:1b3:6980:6169:9414:a8c1:efda:b8c6")) : Host(nome!, myIP);

  GameDataCMD gameData = GameDataCMD(player, portaMulticast);
  RawDatagramSocket? socket;
  String? opcao = ""; 

  while (opcao != "0") {
    print("Opcoes:\n1 - Criar sala\n2 - Entrar na sala\n3 - Print players\n4 - Verificar gameState\n9 - rodar Lopp\n0 - sair");
    opcao = stdin.readLineSync();
    switch (opcao) {
      case "1":
        print("Criando sala");
        print("Iniciando socket");
        socket = await Server.start(portaMulticast, player.myIP);
        
        if (socket != null) {
          print("Meu ip: ${socket.address}");
         Server.startToListen(socket, gameData.processPacket);
         socket.writeEventsEnabled = true;
        } else {
          print("Erro ao criar server");
          return; 
        }
        break;
      case "2":
        print("Entrando em sala");
        if(socket != null) {
          print("Você já está em uma sala");
          break;
        } else {
          print("Iniciando socket");
         
          socket = await Server.start(portaMulticast, player.myIP);
          if (socket != null) {
            Server.startToListen(socket, gameData.processPacket);
            GamePacket packet = GamePacket(
            playerIP: socket.address,
            fromHost: player.isHost, 
            playerNick: player.nick, 
            type: PacketType.newPlayer
          );
          socket.writeEventsEnabled = true;
          socket.send(packet.toString().codeUnits, myIP, portaMulticast);
          }
        }

        break;
      case "3":
        gameData.printPlayers();
        break;
      case "4":
        print("GAME STATE ${gameData.gameState}");
      default:
        break;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
  socket?.close();
}
