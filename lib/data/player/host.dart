
import 'package:quem_sou_eu/data/player/player.dart';
import 'package:quem_sou_eu/data/server/server.dart';

class Host extends Player {
  Host(super.nick);

  List<String> ips = [];
  final Server server = Server();

  @override
  bool get isHost => true;

  List<String> get getIps => ips;

  set addIp(String ip) => ips.add(ip);

  
}
