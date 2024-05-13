enum PacketType {
  newPlayer,
  gameStateChange,
  sendPlayersAlreadyInLobby,
  setToGuess,
  findLobby,
  findLobbyResponse,
  passTurn
}

PacketType? packetTypeFromString(String value) {
  switch (value) {
    case 'PacketType.newPlayer':
      return PacketType.newPlayer;
    case 'PacketType.gameStateChange':
      return PacketType.gameStateChange;
    case 'PacketType.sendPlayersAlreadyInLobby':
      return PacketType.sendPlayersAlreadyInLobby;
    case 'PacketType.setToGuess':
      return PacketType.setToGuess;
    case 'PacketType.findLobby':
      return PacketType.findLobby;
    case 'PacketType.findLobbyResponse':
      return PacketType.findLobbyResponse;
    case 'PacketType.passTurn':
      return PacketType.passTurn;
    default:
      return null;
  }
}