import 'package:chessapp/main_screens/about_screen.dart';
import 'package:chessapp/main_screens/game_time_screen.dart';
import 'package:chessapp/main_screens/settings_screen.dart';
import 'package:chessapp/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/helper_methods.dart';



class HomaScreen extends StatefulWidget {
  const HomaScreen({super.key});

  @override
  State<HomaScreen> createState() => _HomaScreenState();
}

class _HomaScreenState extends State<HomaScreen> {


  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    return Scaffold(
      appBar: AppBar(

        title: Text("Flutter chess", style: TextStyle(color: Colors.white),),

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
        children: [

          buildGameType(label: 'Play vs Computer', icon: Icons.computer,
              onTap: (){
              //navigate to setup game time screen
                gameProvider.setVsComputer(value: true);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>GameTimeScreen()));
            }),
          buildGameType(label: 'Play vs Friend', icon: Icons.person, onTap: (){
            gameProvider.setVsComputer(value: false);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>GameTimeScreen()));
          }),
          buildGameType(label: 'Settings',icon:Icons.settings, onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsScreen()));
          }),
          buildGameType(label: 'About', icon:Icons.info, onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutScreen()));
          }),

        ],),
      )
    );
  }
}


