class LobbyData {
  final String name;
  final String theme;
  final bool hasPassword;
  final int players;
  String? password;
  LobbyData(this.name, this.theme, this.hasPassword, this.players);
}