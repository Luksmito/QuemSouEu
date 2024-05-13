/*import 'dart:io';

import 'package:quem_sou_eu/data/server/server.dart';

void funcaoCallback(String message) {
  print("No callback $message");
}

void main() async {
  RawDatagramSocket? socket1 = await Server.start();
  
  if (socket1 != null) {  
    socket1.joinMulticast(InternetAddress(Server.multicastAddress));
    while (true) {
      String? input = stdin.readLineSync();
      print("Mensagem a ser enviada $input");
      int n = socket1.send(input!.codeUnits, InternetAddress(Server.multicastAddress), Server.multicastPort);
      print("N: $n");
    }
      
  }

  

}*/
