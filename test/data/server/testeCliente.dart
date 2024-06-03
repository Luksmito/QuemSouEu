import 'dart:async';
import 'dart:convert';
import 'dart:io';

void main() async {
  final String targetAddress = '10.0.0.104'; // Substitua pelo endereço IP de destino
  final int targetPort = 6969; // Substitua pela porta de destino

  RawDatagramSocket.bind(InternetAddress.anyIPv4, 6969).then((RawDatagramSocket socket) {
    print('Socket bound to ${socket.address.address}:${socket.port}');

    Timer.periodic(Duration(seconds: 5), (timer) {
      String message = 'Hello, world!';
      List<int> data = utf8.encode(message);
      socket.send(data, InternetAddress(targetAddress), targetPort);
      print('Sent message: $message to $targetAddress:$targetPort');
    });

    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String receivedMessage = utf8.decode(datagram.data);
          print('Received message: $receivedMessage from ${datagram.address.address}:${datagram.port}');
        }
      }
    });
  }).catchError((e) {
    print('Error binding socket: $e');
  });
}