import 'package:flutter/material.dart';

import '../constants.dart';

class PlayerColorRadioButton extends StatelessWidget {
  const PlayerColorRadioButton({Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChange}) : super(key: key);

  final String title;
  final PlayerColor value;
  final PlayerColor? groupValue;
  final Function(PlayerColor?)? onChange;


  @override
  Widget build(BuildContext context) {
    return  RadioListTile<PlayerColor>(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        value: value,
        dense: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        contentPadding: EdgeInsets.zero,
        tileColor: Colors.grey[300],
        groupValue: groupValue,
        onChanged: onChange);
  }
}

class GameLevelRadioButton extends StatelessWidget {
  const GameLevelRadioButton({Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChange}) : super(key: key);

  final String title;
  final GameDifficulty value;
  final GameDifficulty? groupValue;
  final Function(GameDifficulty?)? onChange;


  @override
  Widget build(BuildContext context) {
    final capitalizedTitle=title[0].toUpperCase()+title.substring(1);
    return  Expanded(
      child: RadioListTile<GameDifficulty>(
          title: Text(capitalizedTitle, style: TextStyle(fontWeight: FontWeight.bold),),
          value: value,
          dense: true,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          contentPadding: EdgeInsets.zero,
          tileColor: Colors.grey[300],
          groupValue: groupValue,
          onChanged: onChange),
    );
  }
}



class BuildCustomTime extends StatelessWidget {
  const BuildCustomTime({Key? key, required this.time, required this.onLeftArrowClicked, required this.onRightArrowClicked}) : super(key: key);
  final String time;
  final Function() onLeftArrowClicked;
  final Function() onRightArrowClicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(onTap: time=='0'?null:onLeftArrowClicked

        ,child: Icon(Icons.arrow_back)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: Colors.black,),
                borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(child: Text(time.toString(), textAlign: TextAlign.center,style: TextStyle(fontSize: 20, color: Colors.black),),),
            ),
          ),
        ),
        InkWell(onTap: onRightArrowClicked
        ,child: Icon(Icons.arrow_forward)),
      ]
    );
  }
}


class HaveAccountWidget extends StatelessWidget {
   HaveAccountWidget({Key? key, required this.label, required this.labelAction, required this.onPressed}) : super(key: key);
  final String label;
  final String labelAction;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Text(label, style: TextStyle(fontSize: 16),),
      TextButton(onPressed: onPressed,
          child: Text(labelAction, style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 20),))
    ],);
  }
}


showSnackBar({required BuildContext context, required String content}){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content))
  );
}

