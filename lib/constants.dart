class Constants{
  static const String homeScreen = '/homeScreem';
  static const String gameScreen = '/gameScreen';
  static const String landingScreen = '/landingScreen';
  static const String settingScreen = '/settingScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String gameStartUpScreen = '/gameStartUpScreen';
  static const String gameTimeScreen = '/gameTimeScreen';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String userInfoScreen = '/userInfoScreen';

  static const custom = 'Custom';
  static const uid = 'uid';
  static const name = 'name';
  static const email = 'email';
  static const image = 'image';
  static const createdAt = 'createdAt';
  static const userImages = 'userImages';
  static const users = 'users';
  static const userModel = 'userModel';
  static const isSignedIn = 'isSignedIn';
  static const availableGames = 'availableGames';
  static const photoUrl = 'photoUrl';
  static const gameCreatorUid = 'gameCreatorUid';
  static const gameCreatorName = 'gameCreatorName';
  static const gameCreatorImage = 'gameCreatorImage';
  static const isPlaying = 'isPlaying';
  static const gameId = 'gameId';
  static const dateCreated = 'dateCreated';
  static const whitesTime = 'whitesTime';
  static const blacksTime = 'blacksTime';
  static const userId = 'userId';
  static const posFen = 'posFen';
  static const winnerId = 'winnerId';
  static const whitesCurrentMove = 'whitesCurrentMove';
  static const blacksCurrentMove = 'blacksCurrentMove';
  static const boardState = 'boardState';
  static const playState = 'playState';
  static const isWhitesTurn = 'isWhitesTurn';
  static const isGameOver = 'isGameOver';
  static const squareState = 'squareState';
  static const moves = 'moves';
  static const runningGame = 'runningGame';
  static const game = 'game';

  static const userName = 'userName';
  static const userImage = 'userImage';
  static const gameScore = 'gameScore';

  static const searchingPlayerText = 'Searching for player, please wiat...';
  static const joingGameText = 'Joining game, please wiat';
  static const playerRating = 'playerRating';
  static const gameCreatorRating = 'gameCreatorRating';
  static const userRating = 'userRating';

}

enum PlayerColor{
  white,
  black
}

enum GameDifficulty{
  easy,
  medium,
  hard
}

enum SignInType{
  emailAndPassword,
  guest,
  google,
  facebook
}