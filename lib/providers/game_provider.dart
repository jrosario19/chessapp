import 'dart:async';

import 'package:bishop/bishop.dart';
import 'package:chessapp/constants.dart';
import 'package:chessapp/helper/uci_commands.dart';
import 'package:chessapp/models/game_model.dart';
import 'package:chessapp/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squares/squares.dart' as square;
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:stockfish/stockfish.dart';
import 'package:uuid/uuid.dart';

class GameProvider extends ChangeNotifier{
  late bishop.Game _game=bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state=SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;

  bool _vsComputer = false;
  bool _isLoading = false;
  bool _playWhitesTimer = true;
  bool _playBlacksTimer = true;

  bool get playWhitesTimer => _playWhitesTimer;
  bool get playBlacksTimer => _playBlacksTimer;

  int _gameLavel = 1;
  int _incrementalValue = 0;

  int _player = square.Squares.white;
  PlayerColor _playerColor = PlayerColor.white;
  GameDifficulty _gameDifficulty = GameDifficulty.easy;

  Duration _whitesTime = Duration.zero;
  Duration _blacksTime = Duration.zero;

  Duration _savedWhitesTime = Duration.zero;
  Duration _savedBlacksTime = Duration.zero;


  Timer? get whitesTimer =>_whitesTimer;
  Timer? get blacksTimer =>_blacksTimer;
  int get incrementalValue =>_incrementalValue;
  int get gameLevel =>_gameLavel;
  GameDifficulty get gameDifficulty =>_gameDifficulty;
  bishop.Game get game =>_game;
  SquaresState get state =>_state;
  bool get aiThinking =>_aiThinking;
  bool get flipBoard =>_flipBoard;

  int get player => _player;
  Timer? _whitesTimer;
  Timer? _blacksTimer;
  int _whitesScore = 0;
  int _blacksScore = 0;
  String _gameId = '';

  String get gameId =>_gameId;

  int get whitesScore =>_whitesScore;
  int get blacksScore =>_blacksScore;
  PlayerColor get playerColor => _playerColor;

  Duration get whitesTime =>_whitesTime;
  Duration get blacksTime =>_blacksTime;

  Duration get savedWhitesTime =>_savedWhitesTime;
  Duration get savedblacksTime =>_savedBlacksTime;


  bool get isLoading => _isLoading;
  bool get vsComputer => _vsComputer;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<void> setPlayWhitesTimer({required bool value}) async {
    _playWhitesTimer = value;
    notifyListeners();
  }

  // set play blacksTimer
  Future<void> setPlayBlactsTimer({required bool value}) async {
    _playBlacksTimer = value;
    notifyListeners();
  }

  getPositionFen(){
    return game.fen;
  }

  void resetGame({required bool newGame}){
    if(newGame){
      if(player==square.Squares.white){
        _player=square.Squares.black;
      }else{
        _player = square.Squares.white;

      }
      notifyListeners();
    }
    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
  }

  void flipTheBoard(){
    _flipBoard=!_flipBoard;
    notifyListeners();
  }

  void setAIThinking(bool value){
    _aiThinking=value;
    notifyListeners();
  }


  bool makeSquaresMove(square.Move move){
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  bool makeStringMove(String bestMove) {
    bool result = game.makeMoveString(bestMove);
    notifyListeners();
    return result;
  }

  Future<void> setSquaresState()async{
    _state = game.squaresState(player);
    notifyListeners();
  }

  void makeRandomMove(){
    _game.makeRandomMove();
    notifyListeners();
  }

  void setVsComputer({required bool value}){
    _vsComputer=value;
    notifyListeners();
  }
  void setIsLoading({required bool value}){
    _isLoading=value;
    notifyListeners();
  }

  Future<void> setGameTime({required String newSavedWhitesTime, required String newSavedBlacksTime})async{
    _savedWhitesTime=Duration(minutes: int.parse(newSavedWhitesTime));
    _savedBlacksTime=Duration(minutes: int.parse(newSavedBlacksTime));
    notifyListeners();
    setWhitesTime(_savedWhitesTime);
    setBlacksTime(_savedBlacksTime);
  }

  void setWhitesTime(Duration time){
    _whitesTime=time;
    notifyListeners();
  }

  void setBlacksTime(Duration time){
    _blacksTime=time;
    notifyListeners();
  }

  void setPlayerColor({required int player}){
    _player=player;
    _playerColor = player==square.Squares.white? PlayerColor.white:PlayerColor.black;
    notifyListeners();
  }

  void setGameDifficulty({required int level}){
    _gameLavel = level;
    _gameDifficulty=level==1?GameDifficulty.easy:level==2?GameDifficulty.medium:GameDifficulty.hard;
     notifyListeners();
  }

  void setIncrementalValue({required int value}){
    _incrementalValue=value;
    notifyListeners();
  }

  void pauseWhitesTimer(){
    if(whitesTimer!=null){
      _whitesTime += Duration(seconds: _incrementalValue);
      _whitesTimer!.cancel();
      notifyListeners();
    }
  }

  void pauseBlacksTimer(){
    if(blacksTimer!=null){
      _blacksTime += Duration(seconds: _incrementalValue);
      _blacksTimer!.cancel();
      notifyListeners();
    }
  }


  void startBlacksTimer({required BuildContext context, required Function onNewGame, Stockfish? stockfish}){
    _blacksTimer = Timer.periodic(Duration(seconds: 1), (_){
      _blacksTime = _blacksTime-Duration(seconds: 1);
      notifyListeners();
      if(_blacksTime<=Duration.zero){
        _blacksTimer!.cancel();
        notifyListeners();
        //TODO: show gameover dialog
        if(context.mounted){
          gameOverDialog(context: context,
              timeOut: true,
              whitesWon: true,
              stockfish: stockfish,
              onNewGame: onNewGame);
        }
      }
    });

  }

  void startWhitesTimer({required BuildContext context, required Function onNewGame, Stockfish? stockfish}){
    _whitesTimer = Timer.periodic(Duration(seconds: 1), (_){

      _whitesTime = _whitesTime-Duration(seconds: 1);
      notifyListeners();
      if(_whitesTime<=Duration.zero){
        _whitesTimer!.cancel();
        notifyListeners();
        //TODO: show gameover dialog
        if(context.mounted){
          gameOverDialog(context: context,
              timeOut: true,
              stockfish: stockfish,
              whitesWon: false,
              onNewGame: onNewGame);
        }
      }
    });

  }

  void gameOverListener({required BuildContext context, required Function onNewGame, Stockfish? stockfish}){
    if(game.gameOver){

      pauseWhitesTimer();
      pauseBlacksTimer();

      gameStreamSubscription!.cancel();

      if(context.mounted){
        gameOverDialog(context: context,
            timeOut: false,
            stockfish: stockfish,
            whitesWon: false,
            onNewGame: onNewGame);
      }
    }
  }

  void gameOverDialog({required BuildContext context, required bool timeOut, required bool whitesWon, required Function onNewGame, Stockfish? stockfish}){
    if(stockfish!=null){
      stockfish.stdin=UCICommands.stop;
    }
    String resultsToShow = '';
    int whitesScoresToShow=0;
    int blacksScoresToShow=0;
    if(timeOut){
      if(whitesWon){
        resultsToShow = 'White won on Time';
        whitesScoresToShow=_whitesScore+1;
      }else{
        resultsToShow = 'Black won on Time';
        blacksScoresToShow=_blacksScore+1;
      }
    }else{
      resultsToShow=game.result!.readable;
      if(game.drawn){
        String whitesResults=game.result!.scoreString.split('-').first;
        String blacksResults=game.result!.scoreString.split('-').last;
        whitesScoresToShow= _whitesScore+=int.parse(whitesResults);
        blacksScoresToShow= _blacksScore+=int.parse(blacksResults);
      }else if(game.winner==0){
        String whitesResults=game.result!.scoreString.split('-').first;
        whitesScoresToShow= _whitesScore+=int.parse(whitesResults);
      }else if(game.winner==1){
        String blacksResults=game.result!.scoreString.split('-').last;
        blacksScoresToShow= _blacksScore+=int.parse(blacksResults);
      }else if(game.stalemate){
        whitesScoresToShow=whitesScore;
        blacksScoresToShow=blacksScore;
      }
    }
    showDialog(context: context,
      barrierDismissible:false,
      builder: (context)=>AlertDialog(
        title: Text('Game Over\n $whitesScoresToShow - $blacksScoresToShow', textAlign: TextAlign.center,),
        content: Text(resultsToShow, textAlign: TextAlign.center,),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
            //Navigate to Home Screen
            Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
          }, child: Text('Cancel', style: TextStyle(color: Colors.red),)),
          TextButton(onPressed: (){
            Navigator.pop(context);
            //Reset the game
          }, child: Text('New Game', style: TextStyle(color: Colors.red),))

        ],
      ),
        );
  }

  String _waitingText = '';

  String get waitingText =>_waitingText;

  setWaitingText(){
    _waitingText='';
    notifyListeners();
  }

  Future searchPlayer({
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail
})async{
  try{


    final availableGames = await firebaseFirestore.collection(Constants.availableGames).get();
    if(availableGames.docs.isNotEmpty){
      final List<DocumentSnapshot<Object>> gameList= availableGames.docs.where((element) => element[Constants.isPlaying]==false).toList();
      if(gameList.isEmpty){
        _waitingText=Constants.searchingPlayerText;
        notifyListeners();
        createNewGameInFirestore(
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail);

      }else{
        _waitingText=Constants.joingGameText;
        notifyListeners();
        joinGame(game: gameList.first, userModel: userModel, onSuccess: onSuccess, onFail: onFail);
      }
    }else{
      _waitingText=Constants.searchingPlayerText;
      createNewGameInFirestore(
          userModel: userModel,
          onSuccess: onSuccess,
          onFail: onFail);

    }
  }on FirebaseException catch(e){
    onFail(e.toString());
  }
}
  void createNewGameInFirestore({required UserModel userModel, required Function onSuccess, required Function(String) onFail })async{
    _gameId= Uuid().v4();
    notifyListeners();

    try{
      await firebaseFirestore.collection(Constants.availableGames).doc(userModel.uid).set(
          {
            Constants.uid:'',
            Constants.name:'',
            Constants.photoUrl:'',
            Constants.userRating:1200,
            Constants.gameCreatorUid:userModel.uid,
            Constants.gameCreatorName:userModel.name,
            Constants.gameCreatorImage:userModel.image,
            Constants.gameCreatorRating:userModel.playerRating,
            Constants.isPlaying:false,
            Constants.gameId:gameId,
            Constants.dateCreated:DateTime.now().microsecondsSinceEpoch.toString(),
            Constants.whitesTime:_savedWhitesTime.toString(),
            Constants.blacksTime:_savedBlacksTime.toString(),
          });

      onSuccess();
    }on FirebaseException catch(e){
      onFail(e.toString());
    }
  }

  String _gameCreatorUid = '';
  String _gameCreatorName = '';
  String _gameCreatorPhoto = '';
  int _gameCreatorRating = 1200;
  String _userId ='';
  String _userName ='';
  String _userPhoto ='';
  int _userRating =1200;

  int get gameCreatorRating =>_gameCreatorRating;
  int get userRating =>_userRating;

  String get gameCreatorUid => _gameCreatorUid;
  String get gameCreatorName => _gameCreatorName;
  String get gameCreatorPhoto => _gameCreatorPhoto;
  String get userId =>_userId;
  String get userName =>_userName;
  String get userPhoto =>_userPhoto;

  void joinGame({required DocumentSnapshot<Object> game,
    required UserModel userModel, required Function() onSuccess, required Function(String) onFail})async{
      try{
        final mygame= await firebaseFirestore.collection(Constants.availableGames).doc(userModel.uid).get();
        _gameCreatorUid = game[Constants.gameCreatorUid];
        _gameCreatorName = game[Constants.gameCreatorName];
        _gameCreatorPhoto = game[Constants.gameCreatorImage];
        _gameCreatorRating=game[Constants.gameCreatorRating];
        _userId = userModel.uid;
        _userName = userModel.name;
        _userPhoto = userModel.image;
        _userRating=userModel.playerRating;
        _gameCreatorName = game[Constants.gameCreatorName];
        _gameCreatorName = game[Constants.gameCreatorName];
        _gameId = game[Constants.gameId];
        notifyListeners();

        if(mygame.exists){
          await mygame.reference.delete();
        }

      final gameModel = GameModel(
          gameId: gameId,
          gameCreatorUid: _gameCreatorUid,
          userId: userId,
          posFen: getPositionFen(),
          winnerId: '',
          whitesTime: game[Constants.whitesTime],
          blacksTime: game[Constants.blacksTime],
          whitesCurrentMove: '',
          blacksCurrentMove: '',
          boardState: state.board.flipped().toString(),
          playState: square.PlayState.ourTurn.name.toString(),
          isWhitesTurn: true,
          isGameOver: false,
          squareState: state.player,
          moves: state.moves.toList());

        await firebaseFirestore.collection(Constants.runningGame).doc(gameId).collection(Constants.game).doc(gameId).set(gameModel.toMap());
        await firebaseFirestore.collection(Constants.runningGame).doc(gameId).set(
            {
              Constants.gameCreatorUid:gameCreatorUid,
              Constants.gameCreatorName:gameCreatorName,
              Constants.gameCreatorImage:gameCreatorPhoto,
              Constants.gameCreatorRating:gameCreatorRating,
              Constants.userId:userId,
              Constants.userName:userName,
              Constants.userImage:userPhoto,
              Constants.userRating: userRating,
              Constants.isPlaying:true,
              Constants.dateCreated:DateTime.now().microsecondsSinceEpoch.toString(),
              Constants.gameScore:'0-0'
            });


       await setGameDataAndSetting(game: game, userModel: userModel);
        onSuccess();
      } on FirebaseException catch(e){
        onFail(e.toString());
      }

  }

  StreamSubscription? isPlayingStreamSubscription;

  void checkIfOpponentJoin({required UserModel userModel, required Function() onSucess})async{
    //listen to database availableGames collection changes
    isPlayingStreamSubscription= firebaseFirestore.collection(Constants.availableGames).doc(userModel.uid).snapshots().listen((event) async{
      if(event.exists){
        final DocumentSnapshot game=event;
        if(game[Constants.isPlaying]){
          isPlayingStreamSubscription!.cancel();
          await Future.delayed(Duration(milliseconds: 100));
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _gameCreatorPhoto = game[Constants.gameCreatorImage];
          _userId = game[Constants.uid];
          _userName = game[Constants.name];
          _userPhoto = game[Constants.photoUrl];
          setPlayerColor(player: 0);
          notifyListeners();
          onSucess();
        }
      }
    });
  }

  Future<void> setGameDataAndSetting(
  {required DocumentSnapshot<Object> game,
    required UserModel userModel
  })async{
    final opponentGame= firebaseFirestore.collection(Constants.availableGames).doc(game[Constants.gameCreatorUid]);
    List<String> whitesTimeParts= game[Constants.whitesTime].split(':');
    List<String> blacksTimeParts= game[Constants.blacksTime].split(':');

    int whitesGametime = int.parse(whitesTimeParts[0])*60+int.parse(whitesTimeParts[1]);
    int blacksGametime =int.parse(blacksTimeParts[0])*60+int.parse(blacksTimeParts[1]);

    await setGameTime(
        newSavedWhitesTime: whitesGametime.toString(),
        newSavedBlacksTime: blacksGametime.toString());

    await opponentGame.update({
      Constants.isPlaying:true,
      Constants.uid:userModel.uid,
      Constants.name:userModel.name,
      Constants.photoUrl:userModel.image,
      Constants.userRating:userModel.playerRating
    });
    setPlayerColor(player: 1);
    notifyListeners();
  }


  bool _isWhiteTurn = true;
  String blacksMove = '';
  String whitessMove = '';
  bool get isWhiteTurn => _isWhiteTurn;
  StreamSubscription? gameStreamSubscription;

  //listen for game changes in firestore
  Future<void> listenForGameChanges({required BuildContext context, required UserModel userModel})async{
    CollectionReference gameCollectionReference=firebaseFirestore.collection(Constants.runningGame).doc(gameId).collection(Constants.game);
    gameStreamSubscription= gameCollectionReference.snapshots().listen((event) {
      if(event.docs.isNotEmpty){
        final DocumentSnapshot game = event.docs.first;
        if(game[Constants.gameCreatorUid]==userModel.uid){
          if(game[Constants.isWhitesTurn]){
            _isWhiteTurn=true;

            if(game[Constants.blacksCurrentMove]!=blacksMove){
              square.Move  convertedMove = convertMoveStringToMove(moveString: game[Constants.blacksCurrentMove]);
              bool result = makeSquaresMove(convertedMove);
              if(result){
                setSquaresState().whenComplete(() {
                  pauseBlacksTimer();
                  startWhitesTimer(context: context, onNewGame: (){});
                  gameOverListener(context: context, onNewGame: (){});
                });
              }
            }
          notifyListeners();
          }
        }else{
          //not the game creator
          _isWhiteTurn=false;
          if(game[Constants.whitesCurrentMove]!=whitessMove){
            square.Move  convertedMove = convertMoveStringToMove(moveString: game[Constants.whitesCurrentMove]);
            bool result = makeSquaresMove(convertedMove);
            if(result){
              setSquaresState().whenComplete(() {
                pauseWhitesTimer();
                startBlacksTimer(context: context, onNewGame: (){});
                gameOverListener(context: context, onNewGame: (){});
              });
            }
          }
          notifyListeners();
        }
      }
    });
  }

  square.Move convertMoveStringToMove({required String moveString}){
    List<String> parts = moveString.split('-');
    int from = int.parse(parts[0]);
    int to = int.parse(parts[1].split('[')[0]);

    String? promo;
    String? piece;
    if(moveString.contains('[')){
      String extras = moveString.split('[')[1].split(']')[0];
      List<String> extrasList = extras.split(',');
      promo = extrasList[0];
      if(extrasList.length>1){
        piece = extrasList[1];
      }
    }
    return square.Move(from: from, to: to, promo: promo, piece: piece);
  }

  Future<void> playMoveAndSavetoFirestore({required BuildContext context, required square.Move move, required bool isWhiteMove})async{
    if(isWhiteMove){
      await firebaseFirestore.collection(Constants.runningGame).doc(gameId).collection(Constants.game).doc(gameId).update(
          {
            Constants.posFen:getPositionFen(),
            Constants.whitesCurrentMove:move.toString(),
            Constants.moves:FieldValue.arrayUnion([move.toString()]),
            Constants.isWhitesTurn:false,
            Constants.playState:square.PlayState.theirTurn.name.toString(),
          });
      pauseWhitesTimer();
      
      Future.delayed(Duration(milliseconds: 100)).whenComplete(() {
        startBlacksTimer(context: context, onNewGame: (){});
      });
    }else{
      await firebaseFirestore.collection(Constants.runningGame).doc(gameId).collection(Constants.game).doc(gameId).update(
          {
            Constants.posFen:getPositionFen(),
            Constants.blacksCurrentMove:move.toString(),
            Constants.moves:FieldValue.arrayUnion([move.toString()]),
            Constants.isWhitesTurn:true,
            Constants.playState:square.PlayState.ourTurn.name.toString(),
          });
      pauseBlacksTimer();
      Future.delayed(Duration(milliseconds: 100)).whenComplete(() {
        startWhitesTimer(context: context, onNewGame: (){});
      });
    }
  }
}