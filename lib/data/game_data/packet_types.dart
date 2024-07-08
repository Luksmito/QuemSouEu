enum PacketType {
  newPlayer,
  gameStateChange,
  sendPlayersAlreadyInLobby,
  setToGuess,
  findLobby,
  findLobbyResponse,
  passTurn,
  quitGame, 
  restartGame,
  createLobby,
  listLobbys,
  playerDisconnect,
  packetResponse,
  chatMessage,
  question,
  tryingToReconnect,
  reconnected
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
    case 'PacketType.quitGame':
      return PacketType.quitGame;
    case 'PacketType.restartGame':
      return PacketType.restartGame;
    case 'PacketType.createLobby':
      return PacketType.createLobby;
    case 'PacketType.listLobbys':
      return PacketType.listLobbys;
    case 'PacketType.playerDisconnect':
      return PacketType.playerDisconnect;
    case 'PacketType.packetResponse':
      return PacketType.packetResponse;
    case 'PacketType.chatMessage':
      return PacketType.chatMessage;
    case 'PacketType.question':
      return PacketType.question;
    case 'PacketType.tryingToReconnect':
      return PacketType.tryingToReconnect;
    case 'PacketType.reconnected':
      return PacketType.reconnected;
    default:
      return null;
  }
}