import 'package:chessapp/helper/helper_methods.dart';
import 'package:chessapp/helper/uci_commands.dart';
import 'package:chessapp/models/user_model.dart';
import 'package:chessapp/providers/authentication_provider.dart';
import 'package:chessapp/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:chessapp/service/assets_manager.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:stockfish/stockfish.dart';

import '../constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  late Stockfish stockfish;
  @override
  void initState() {
    stockfish=Stockfish();
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);
    if(mounted){

      letOtherPlayerPlayFirst();
    }
    super.initState();
  }

  @override
  void dispose() {
    stockfish.dispose();
    super.dispose();
  }

  void letOtherPlayerPlayFirst(){

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final gameProvider = context.read<GameProvider>();
      if(gameProvider.vsComputer){
        if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {
          gameProvider.setAIThinking(true);
          await Future.delayed(
              Duration(milliseconds: Random().nextInt(4750) + 250));
          gameProvider.game.makeRandomMove();
          gameProvider.setAIThinking(false);
          gameProvider.setSquaresState().whenComplete(() {
            if (gameProvider.player == Squares.white) {
              // check if we can play whitesTimer
              if (gameProvider.playWhitesTimer) {
                // pause timer for black
                gameProvider.pauseBlacksTimer();

                startTimer(
                  isWhitesTimer: true,
                  onNewGame: () {},
                );

                gameProvider.setPlayWhitesTimer(value: false);
              }
            } else {
              if (gameProvider.playBlacksTimer) {
                // pause timer for white
                gameProvider.pauseWhitesTimer();

                startTimer(
                  isWhitesTimer: false,
                  onNewGame: () {},
                );

                gameProvider.setPlayBlactsTimer(value: false);
              }
            }
          });
        }
      }else{
        final userModel = context.read<AuthenticatioProvider>().userModel;
        //listen for game changes in firestore
        gameProvider.listenForGameChanges(context: context, userModel: userModel!);
      }
    });
  }


  void _onMove(Move move) async {
    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.makeSquaresMove(move);

    if (result) {

      gameProvider.setSquaresState().whenComplete(() async{

        if(gameProvider.player==Squares.white){
          if(gameProvider.vsComputer){
            gameProvider.pauseWhitesTimer();
            startTimer(isWhitesTimer: false, onNewGame: (){

            });
            gameProvider.setPlayWhitesTimer(value: true);
          }else{
            await gameProvider.playMoveAndSavetoFirestore(context: context, move: move, isWhiteMove: true);
          }

        }else{
          if(gameProvider.vsComputer){
            gameProvider.pauseBlacksTimer();
            startTimer(isWhitesTimer: true, onNewGame: (){

            });
            gameProvider.setPlayBlactsTimer(value: true);
          }else{
            await gameProvider.playMoveAndSavetoFirestore(context: context, move: move, isWhiteMove: false);
          }

        }

      });

    }
    if(gameProvider.vsComputer){
      if (gameProvider.state.state == PlayState.theirTurn && !gameProvider.aiThinking) {

        gameProvider.setAIThinking(true);


        await waitUntilReady();
        stockfish.stdin ='${UCICommands.position} ${gameProvider.getPositionFen()}';
        stockfish.stdin = '${UCICommands.goMoveTime} ${gameProvider.gameLevel*1000}';

        stockfish.stdout.listen((event) {
          if(event.contains(UCICommands.bestMove)){
            final bestMove = event.split(' ')[1];
            print(bestMove);
            gameProvider.makeStringMove(bestMove);
            gameProvider.setAIThinking(false);
            gameProvider.setSquaresState().whenComplete(() {
              if(gameProvider.player==Squares.white){
                gameProvider.pauseBlacksTimer();
                startTimer(isWhitesTimer: true, onNewGame: (){

                });
              }else{
                gameProvider.pauseWhitesTimer();
                startTimer(isWhitesTimer: false, onNewGame: (){

                });
              }

            });
          }
        });




        // gameProvider.setSquaresState().whenComplete(() {
        //   if(gameProvider.player==Squares.white){
        //     gameProvider.pauseBlacksTimer();
        //     startTimer(isWhitesTimer: true, onNewGame: (){
        //
        //     });
        //   }else{
        //     gameProvider.pauseWhitesTimer();
        //     startTimer(isWhitesTimer: false, onNewGame: (){
        //
        //     });
        //   }
        //
        // });

      }
    }

    await Future.delayed(Duration(seconds: 1));
    checkGameOverListener();
  }

  Future<void> waitUntilReady()async{
    while(stockfish.state.value != StockfishState.ready){
      await Future.delayed( const Duration(seconds: 1));
    }
    print('State1:'+ stockfish.state.value.toString());
  }

  void checkGameOverListener(){
    final gameProvider = context.read<GameProvider>();
    gameProvider.gameOverListener(
        context: context,
        stockfish: stockfish,
        onNewGame: (){

    },);
  }

  void startTimer({required bool isWhitesTimer, required Function onNewGame}){
    final gameProvider = context.read<GameProvider>();
    if(isWhitesTimer){
      gameProvider.startWhitesTimer(context: context, onNewGame: onNewGame, stockfish: stockfish);
    }else{
      gameProvider.startBlacksTimer(context: context, onNewGame: onNewGame, stockfish: stockfish);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final userModel = context.read<AuthenticatioProvider>().userModel;
    return WillPopScope(
      onWillPop: ()async{
        bool? leave= await _showExitConfirmDialog(context);
        if(leave!=null&&leave){
          stockfish.stdin=UCICommands.stop;
          await Future.delayed(Duration(milliseconds: 200)).whenComplete((){
            Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
          });

        }
        return false;;
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          //   //TODO show dialog if sure
          //   Navigator.pop(context);
          // },color: Colors.white,),
          title: Text("Flutter chess", style: TextStyle(color: Colors.white),),
          actions: [
            const SizedBox(height: 32),
            IconButton(
              onPressed: (){
                gameProvider.resetGame(newGame: false);
              },
              icon: const Icon(Icons.start,color: Colors.white),
            ),
            IconButton(
              onPressed: (){
                gameProvider.flipTheBoard();
              },
              icon: const Icon(Icons.rotate_left, color: Colors.white),
            ),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, child){
            String whitesTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: true);
            String blacksTimer = getTimerToDisplay(gameProvider: gameProvider, isUser: false);
          return Center(
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //oponent data
                showOpponentData(gameProvider: gameProvider, userModel: userModel!, timeToShow: blacksTimer),

                gameProvider.vsComputer? Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: BoardController(
                    state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
                    playState: gameProvider.state.state,
                    pieceSet: PieceSet.merida(),
                    theme: BoardTheme.brown,
                    moves: gameProvider.state.moves,
                    onMove: _onMove,
                    onPremove: _onMove,
                    markerTheme: MarkerTheme(
                      empty: MarkerTheme.dot,
                      piece: MarkerTheme.corners(),
                    ),
                    promotionBehaviour: PromotionBehaviour.autoPremove,
                  )):buildChessBoard(gameProvider: gameProvider, userModel: userModel),

                //our data
                ListTile(
                  leading:

                  userModel.image==''? CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(AssetsManager.userIcon),
                  ):CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userModel.image),
                  ),
                  title: Text(userModel.name),
                  subtitle: Text('Rating: ${userModel.playerRating}'),
                  trailing: Text(whitesTimer, style: TextStyle(fontSize: 16)),
                ),

              ],
            ),
          );
          },

        ),
      ),
    );;
  }

  Widget buildChessBoard({required GameProvider gameProvider, required UserModel userModel}){
    bool isOurTurn= gameProvider.isWhiteTurn ==(gameProvider.gameCreatorUid==userModel.uid);

    return BoardController(
      state: gameProvider.flipBoard ? gameProvider.state.board.flipped() : gameProvider.state.board,
      playState: isOurTurn?PlayState.ourTurn:PlayState.theirTurn,
      pieceSet: PieceSet.merida(),
      theme: BoardTheme.brown,
      moves: gameProvider.state.moves,
      onMove: _onMove,
      onPremove: _onMove,
      markerTheme: MarkerTheme(
        empty: MarkerTheme.dot,
        piece: MarkerTheme.corners(),
      ),
      promotionBehaviour: PromotionBehaviour.autoPremove,
    );
  }

  getState({required GameProvider gameProvider}){
    if(gameProvider.flipBoard){
       return gameProvider.state.board.flipped();
    }else{
      gameProvider.state.board;
    }
  }

  Widget showOpponentData({required GameProvider gameProvider, required UserModel userModel, required String timeToShow}){
    if(gameProvider.vsComputer){
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.stockfishIcon),
        ),
        title: Text('Stockfish'),
        subtitle: Text('Rating: ${gameProvider.gameLevel*1000}'),
        trailing: Text(timeToShow, style: TextStyle(fontSize: 16),),
      );
    }else{
      if(gameProvider.gameCreatorUid ==userModel.uid){
        return    ListTile(
          leading:

          gameProvider.userPhoto==''? CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          ):CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.userPhoto),
          ),
          title: Text(gameProvider.userName),
          subtitle: Text('Rating: ${gameProvider.userRating}'),
          trailing: Text(timeToShow, style: TextStyle(fontSize: 16)),
        );
      }else{
        return    ListTile(
          leading:

          gameProvider.gameCreatorPhoto==''? CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AssetsManager.userIcon),
          ):CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(gameProvider.gameCreatorPhoto),
          ),
          title: Text(gameProvider.gameCreatorName),
          subtitle: Text('Rating: ${gameProvider.gameCreatorRating}'),
          trailing: Text(timeToShow, style: TextStyle(fontSize: 16)),
        );
      }
    }
  }

  Future<bool?> _showExitConfirmDialog(BuildContext context) async{
    return showDialog<bool>(context: context, builder: (context)=>AlertDialog(
      title: Text('Leave Game?', textAlign: TextAlign.center,),
      content: Text('Are you sure to leave this game?', textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: Text('Cancel')),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: Text('Yes'))
      ],
    ));
  }
}
