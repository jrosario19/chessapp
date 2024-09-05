import 'dart:async';

import 'package:bishop/bishop.dart';
import 'package:chessapp/constants.dart';
import 'package:chessapp/helper/uci_commands.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squares/squares.dart' as square;
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:stockfish/stockfish.dart';

class GameProvider extends ChangeNotifier{
  late bishop.Game _game=bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state=SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;

  bool _vsComputer = false;
  bool _isLoading = false;

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

  int get whitesScore =>_whitesScore;
  int get blacksScore =>_blacksScore;
  PlayerColor get playerColor => _playerColor;

  Duration get whitesTime =>_whitesTime;
  Duration get blacksTime =>_blacksTime;

  Duration get savedWhitesTime =>_savedWhitesTime;
  Duration get savedblacksTime =>_savedBlacksTime;


  bool get isLoading => _isLoading;
  bool get vsComputer => _vsComputer;

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
      _whitesTime += Duration(seconds: incrementalValue);
      _whitesTimer!.cancel();
      notifyListeners();
    }
  }

  void pauseBlacksTimer(){
    if(blacksTimer!=null){
      _blacksTime += Duration(seconds: incrementalValue);
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
  // String getResultToShow({required bool whitesWon}){
  //   if(whitesWon){
  //     return 'White won on Time';
  //   }else{
  //     return 'Black won on Time';
  //   }
  // }
}