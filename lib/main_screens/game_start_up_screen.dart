import 'package:chessapp/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../widgets/widgets.dart';

class GameStartUpScreen extends StatefulWidget {
  const GameStartUpScreen({super.key, required  this.isCustomTime, required this.gameTime});

  final bool isCustomTime;
  final String gameTime;

  @override
  State<GameStartUpScreen> createState() => _GameStartUpScreenState();
}

class _GameStartUpScreenState extends State<GameStartUpScreen> {
  PlayerColor playerColorGroup= PlayerColor.white;
  GameDifficulty gameLevelGroup= GameDifficulty.easy;

  int whiteTimInMinutes=0;
  int blackTimInMinutes=0;
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white,),
          ),
          title: Text('Setup Game', style: TextStyle(color: Colors.white),),
        ),
        body: Padding(
        padding: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.5,
              child: PlayerColorRadioButton(
                  title: 'Play as ${PlayerColor.white.name}',
                  value: PlayerColor.white,
                  groupValue: gameProvider.playerColor,
                  onChange: (value){
                    gameProvider.setPlayerColor(player: 0);
                  }),
            ),
            widget.isCustomTime? BuildCustomTime(time: whiteTimInMinutes.toString(),
                onLeftArrowClicked: (){
                  setState(() {
                    whiteTimInMinutes--;
                  });
                }, onRightArrowClicked: (){
                  setState(() {
                    whiteTimInMinutes++;
                  });
                }) :Container(
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.black,),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(child: Text(widget.gameTime, textAlign: TextAlign.center,style: TextStyle(fontSize: 20, color: Colors.black),),),
              ),
            )
          ],
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.5,
              child: PlayerColorRadioButton(
                  title: 'Play as ${PlayerColor.black.name}',
                  value: PlayerColor.black,
                  groupValue: gameProvider.playerColor,
                  onChange: (value){

                    gameProvider.setPlayerColor(player: 1);
                  }),
            ),
            widget.isCustomTime? BuildCustomTime(time: blackTimInMinutes.toString(),
                onLeftArrowClicked: (){
                  setState(() {
                    blackTimInMinutes--;
                  });
                }, onRightArrowClicked: (){
                  setState(() {
                    blackTimInMinutes++;
                  });
                }) :Container(
              height: 39,
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.black,),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(child: Text(widget.gameTime, textAlign: TextAlign.center,style: TextStyle(fontSize: 20, color: Colors.black),),),
              ),
            )
          ],
        ),
        gameProvider.vsComputer?Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Game Difficulty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              GameLevelRadioButton(title: GameDifficulty.easy.name,
                  value: GameDifficulty.easy,
                  groupValue: gameProvider.gameDifficulty, onChange: (value){
                    gameProvider.setGameDifficulty(level: 1);
                  }),
              SizedBox(width: 10,),
              GameLevelRadioButton(title: GameDifficulty.medium.name,
                  value: GameDifficulty.medium,
                  groupValue: gameProvider.gameDifficulty, onChange: (value){
                    gameProvider.setGameDifficulty(level: 2);              }),
            SizedBox(width: 10,),
              GameLevelRadioButton(title: GameDifficulty.hard.name,
                  value: GameDifficulty.hard,
                  groupValue: gameProvider.gameDifficulty, onChange: (value){
                    gameProvider.setGameDifficulty(level: 3);
                  })
            ],)
          ],
        ):SizedBox.shrink(),
        SizedBox(height: 20,),
        ElevatedButton(onPressed: (){
          playGame(gameProvider: gameProvider);
        }, child: Text('Play'))
      ],),
    )));
  }

  void playGame({required GameProvider gameProvider}) async {
    if(widget.isCustomTime){
      if(whiteTimInMinutes<=0||blackTimInMinutes<=0){
        showSnackBar(context: context, content: 'Time can not be 0');
        return;
      }
      gameProvider.setIsLoading(value: true);
      await gameProvider.setGameTime(newSavedWhitesTime: whiteTimInMinutes.toString(),
          newSavedBlacksTime: blackTimInMinutes.toString()).whenComplete(() {
            if(gameProvider.vsComputer){
              gameProvider.setIsLoading(value: false);
              Navigator.pushNamed(context,  Constants.gameScreen);
            }else{

            }
      } );

    }else{
      final String incrementalTime = widget.gameTime.split('+')[1];
      final String gameTime = widget.gameTime.split('+')[0];
      if(incrementalTime!=0){
        gameProvider.setIncrementalValue(value:int.parse(incrementalTime));
      }
      gameProvider.setIsLoading(value: true);
      await gameProvider.setGameTime(newSavedWhitesTime:gameTime,
          newSavedBlacksTime: gameTime).whenComplete(() {
        if(gameProvider.vsComputer){
          Navigator.pushNamed(context,  Constants.gameScreen);
        }else{
          //search for player
        }
      });
    }

  }
}





