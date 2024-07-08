import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:quem_sou_eu/data/game_data/game_packet.dart';
import 'package:quem_sou_eu/data/game_data/packet_types.dart';

class GameClient {
  final String serverIp;
  final int serverPort;
  final Duration heartbeatInterval = const Duration(seconds: 5);
  final Function(String, dynamic) callback;

  SecureSocket? _socket;
  bool _connected = false;
  GameClient(this.serverIp, this.serverPort, this.callback);
  bool _tryToReconnect = true;
  int reconnectTries = 0;
  int maxReconnectTries = 3;

  Future<void> connect() async {
    var context = await getClientSecurityContext();
    while (!_connected) {
      try {
        _socket = await SecureSocket.connect(serverIp, serverPort,
            context: context, onBadCertificate: (certificate) => true);
        _connected = true;
        sendReconnectedPacket();
        reconnectTries = 0;
        print('Conectado ao servidor');
        Timer.periodic(heartbeatInterval, (timer) => _sendHeartbeat());
        _socket!.listen(
          (data) {
            callback(utf8.decode(data), _socket);
          },
          onDone: () {
            _connected = false;
            print('Desconectado do servidor');
            sendDisconnectedPacket();
            _reconnect();
          },
          onError: (error) {
            _connected = false;
            print('Erro: $error');
            sendDisconnectedPacket();
            _reconnect();
          },
        );
      } catch (e) {
        print("Reconnect tries: $reconnectTries");
        if (reconnectTries < maxReconnectTries) {
        reconnectTries++;
        _connected = false;
        _socket?.destroy();
      } else {
        _tryToReconnect = false;
        GamePacket quitGame = GamePacket(
            fromHost: true,
            playerNick: "",
            type: PacketType.quitGame,
            playerIP: InternetAddress("0.0.0.0"));
        callback(quitGame.toString(), _socket);
        close();
        _connected = true;
      }
        await Future.delayed(Duration(seconds: 5));
      }
    }
  }

  void sendDisconnectedPacket() {
    GamePacket disconnected = GamePacket(
            fromHost: true,
            playerNick: "",
            type: PacketType.tryingToReconnect,
            playerIP: InternetAddress("0.0.0.0"));
    callback(disconnected.toString(), _socket);
  }

  void sendReconnectedPacket() {
    GamePacket reconnected = GamePacket(
            fromHost: true,
            playerNick: "",
            type: PacketType.reconnected,
            playerIP: InternetAddress("0.0.0.0"));
    callback(reconnected.toString(), _socket);
  }

  Future<SecurityContext> getClientSecurityContext() async {
    final ByteData trustedCertData =
        await rootBundle.load('lib/assets/certificate.pem');

    final SecurityContext context = SecurityContext();
    context.setTrustedCertificatesBytes(trustedCertData.buffer.asUint8List());

    return context;
  }

  void _sendHeartbeat() {
    if (_connected && _socket != null) {
      _socket!.write('heartbeat\n');
    }
  }

  void _reconnect() {
    print("Reconnect tries: $reconnectTries");
    if (_tryToReconnect) {
      if (reconnectTries < maxReconnectTries) {
        reconnectTries++;
        _connected = false;
        _socket?.destroy();
        connect();
      } else {
        _tryToReconnect = false;
        GamePacket quitGame = GamePacket(
            fromHost: true,
            playerNick: "",
            type: PacketType.quitGame,
            playerIP: InternetAddress("0.0.0.0"));
        callback(quitGame.toString(), _socket);
      }
    }
  }

  void close() {
    _connected = false;
    _tryToReconnect = false;
    _socket?.close();
    _socket?.destroy();
  }

  void write(String packet) {
    if (_connected) {
      _socket!.write(packet);
    }
  }
}

void main() async {
  final client = GameClient('127.0.0.1', 55656, (a, b) => print("teste"));
  await client.connect();
}
