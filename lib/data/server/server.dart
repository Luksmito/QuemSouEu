
import 'dart:async';
import 'dart:io';

class Server {
  static const String multicastAddress = 'ff02::1'; // Endereço de multicast IPv6

  static void startToListen(
      RawDatagramSocket socket, Function(String, RawDatagramSocket) callback) async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var address in interface.addresses) {
          // Verifique se o endereço é do tipo IPv6 e não é um loopback
          if (address.type == InternetAddressType.IPv6 && !address.isLoopback) {
            try {
              // Junte-se ao grupo de multicast nesta interface
              print(interface);
              socket.joinMulticast(InternetAddress(Server.multicastAddress), interface);
            } catch (e) {
              print('Erro ao se juntar ao multicast: $e');
            }
            break;
          }
        }
      }
    } on Exception catch (e) {
      print("ERRO $e");
    }
    print("ESCUTANDO");
    socket.multicastHops = 20;
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String message = String.fromCharCodes(datagram.data);
          callback(message, socket);
        }
        socket.readEventsEnabled = true;
      }
    }, onError: (e) => print("onError"), onDone: () {
      print("socket Fechado");
      socket.close();
    });
  }

  static Future<RawDatagramSocket?> start(int port) async {
    try {
      return await RawDatagramSocket.bind(InternetAddress.anyIPv6, port);
    } catch (e) {
      print("Erro $e");
      return null;
    }
  }
}

/*
import 'dart:async';
import 'dart:io';

class Server {
  static const String multicastAddress = '239.255.1.1';

  
  static void startToListen(RawDatagramSocket socket, Function(String, RawDatagramSocket) callback) async{
    
    try {
       final interfaces = await NetworkInterface.list();
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        // Verifique se o endereço é do tipo IPv4 e não é um loopback
        if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
          try {
            // Junte-se ao grupo de multicast nesta interface
            print(interface);
            socket.joinMulticast(InternetAddress(Server.multicastAddress), interface);
          } catch (e) {
            print('Erro ao se juntar ao multicast: $e');
          }
        }
      }
    }
      
    } on Exception catch (e) {
      print("ERRO $e");
    }
    print("ESCUTANDO");
    socket.multicastHops = 20;
    socket.broadcastEnabled = true;
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
      }  
    );
  }

  static Future<RawDatagramSocket?> start(int port) async {
    try {
      return await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    } catch (e) {
      print("Erro $e");
      return null;
    } 
  }



}*/

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