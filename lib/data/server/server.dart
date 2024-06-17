import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

//ec2-18-188-125-150.us-east-2.compute.amazonaws.com
class Server {
  static int portServer = 55656;
  static String addressServer =
      "10.0.0.102";

  static void startToListen(RawDatagramSocket socket,
      Function(String, RawDatagramSocket) callback) async {
    try {
      socket.listen(
          (RawSocketEvent event) {
            if (event == RawSocketEvent.read) {
              Datagram? datagram = socket.receive();
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
      if (!interface.name.contains("rmnet") &&
          !interface.name.contains("WSL")) {
        for (var address in interface.addresses) {
          // Verifique se o endereço é do tipo IPv4 e não é um loopback
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address;
          }
        }
      }
    }
  }

  static Future<SecureSocket> connect() async {
    var context = await getClientSecurityContext();
    return SecureSocket.connect(addressServer, portServer,
        context: context,
        onBadCertificate: (X509Certificate certificate) => true);
  }

  static Future<SecurityContext> getClientSecurityContext() async {
    final ByteData trustedCertData =
        await rootBundle.load('lib/assets/certificate.pem');

    final SecurityContext context = SecurityContext();
    context.setTrustedCertificatesBytes(trustedCertData.buffer.asUint8List());

    return context;
  }

  static Future<SecureSocket> startClient(
      Function(String, dynamic) callback) async {
    var context = await getClientSecurityContext();
    SecureSocket socket = await SecureSocket.connect(addressServer, portServer,
        context: context,
        onBadCertificate: (X509Certificate certificate) => true);
    socket.listen(
      (data) {
        callback(utf8.decode(data), socket);
      },
      onDone: () {
        print('Server disconnected.');
        socket.destroy();
      },
      onError: (error) {
        print('Error: $error');
        socket.destroy();
      },
    );
    return socket;
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