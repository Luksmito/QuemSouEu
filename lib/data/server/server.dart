
import 'dart:async';
import 'dart:io';

class Server {
  static void startToListen(RawDatagramSocket socket,
      Function(String, RawDatagramSocket) callback) async {
    try {
      socket.listen(
          (RawSocketEvent event) {
            if (event == RawSocketEvent.read) {
              Datagram? datagram = socket.receive();
              print("RECEIVED");
              if (datagram != null) {
                String message = String.fromCharCodes(datagram.data);
                callback(message, socket);
              }
              socket.readEventsEnabled = true;
            }
          },
          onError: (e) => print("onError"),
          onDone: () {
            print("socket Fechado");
            socket.close();
          });
    } catch (e) {
      print("Erro ao ouvir: $e");
    }
  }

  static getIP() async {
    final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      if (!interface.name.contains("rmnet") && !interface.name.contains("WSL")) {
        for (var address in interface.addresses) {
          // Verifique se o endereço é do tipo IPv4 e não é um loopback
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address;
          }
        }
      }
    }
  }

  static Future<RawDatagramSocket?> start(int port, InternetAddress ip) async {
    try {
      RawDatagramSocket socket = await RawDatagramSocket.bind(ip, port);
      return socket;
    } catch (e) {
      print("Erro $e");
      return null;
    }
  }
}

/*import 'dart:async';
import 'dart:io';

class Server {
  static const String multicastAddress= '255.255.255.255';
  
  static void startToListen(RawDatagramSocket socket, Function(String, RawDatagramSocket) callback) async {
    try {
      // Configure o socket para permitir o envio de pacotes para o endereço de broadcast
      socket.broadcastEnabled = true;
    } catch (e) {
      print('Erro ao habilitar o broadcast: $e');
      return;
    }

    print("ESCUTANDO");

    socket.listen((RawSocketEvent event) {     
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String message = String.fromCharCodes(datagram.data);
          callback(message, socket);
        } 
        socket.readEventsEnabled = true;
      }
    }, onError: (e) => print("onError"),
    onDone: () {
      print("socket Fechado");
      socket.close();
    });
  }

  static Future<RawDatagramSocket?> start(int port) async {
    try {
      // Crie o socket UDP
      var socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      // Permita que o socket envie pacotes de broadcast
      socket.broadcastEnabled = true;
      return socket;
    } catch (e) {
      print("Erro $e");
      return null;
    } 
  }
}
*/