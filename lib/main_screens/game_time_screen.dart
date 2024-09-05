import 'package:chessapp/helper/helper_methods.dart';
import 'package:chessapp/main_screens/game_start_up_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class GameTimeScreen extends StatefulWidget {
  const GameTimeScreen({super.key});

  @override
  State<GameTimeScreen> createState() => _GameTimeScreenState();
}

class _GameTimeScreenState extends State<GameTimeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white,),
        ),
        title: Text('Choose Game Time', style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 1.5),
            itemCount: gameTimes.length,
            itemBuilder: (context,index){
              final String label = gameTimes[index].split(' ')[0];

              final String gameTime = gameTimes[index].split(' ')[1];

              return buildGameType(label: label, gameTime: gameTime,onTap: (){
                if(label==Constants.custom){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GameStartUpScreen(
                    isCustomTime: true,
                    gameTime: gameTime
                  )));
                }else{
                  print("Selected game time: $index");
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GameStartUpScreen(
                      isCustomTime: false,
                      gameTime: gameTime
                  )));
                }

              });
            }),
      )
    );;
  }
}
