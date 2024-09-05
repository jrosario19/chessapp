
import 'package:chessapp/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:squares/squares.dart';

Widget buildGameType({ required String label, String? gameTime, IconData? icon, required Function() onTap}){
  return InkWell(
    onTap: onTap,
    child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!=null?Icon(icon):gameTime! =='60+0'?SizedBox.shrink(): Text(gameTime!),
          SizedBox(height: 10,),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      ),
    ),
  );
}

String getTimerToDisplay({required GameProvider gameProvider, required bool isUser}){
  String timer = '';
  if(isUser){
    if(gameProvider.player==Squares.white){
      timer = gameProvider.whitesTime.toString().substring(2,7);
    }
    if(gameProvider.player==Squares.black){
      timer = gameProvider.blacksTime.toString().substring(2,7);
    }
  }else{
    if(gameProvider.player==Squares.white){
      timer = gameProvider.blacksTime.toString().substring(2,7);
    }
    if(gameProvider.player==Squares.black){
      timer = gameProvider.whitesTime.toString().substring(2,7);
    }
  }
  return timer;
}



final List<String> gameTimes=[
  'Bullet 1+0',
  'Bullet 2+1',
  'Bullet 3+0',
  'Blitz 3+2',
  'Blitz 5+0',
  'Blitz 5+3',
  'Rapid 10+0',
  'Rapid 10+5',
  'Rapid 15+10',
  'Classical 30+0',
  'Classical 30+20',
  'Custom 60+0',
];

var textFormDecoration=InputDecoration(
    hintText: 'Enter your Email',
    labelText: 'Enter your Email',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),

    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.lightBlue,
        width: 1,
      ),
      borderRadius:  BorderRadius.circular(8),

    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.orangeAccent,
        width: 1,
      ),
      borderRadius:  BorderRadius.circular(8),
    )

);