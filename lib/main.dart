import 'package:chessapp/authentication/login_screen.dart';
import 'package:chessapp/authentication/sign_up_screen.dart';
import 'package:chessapp/main_screens/about_screen.dart';
import 'package:chessapp/main_screens/game_screen.dart';
import 'package:chessapp/main_screens/game_start_up_screen.dart';
import 'package:chessapp/main_screens/game_time_screen.dart';
import 'package:chessapp/main_screens/home_screen.dart';
import 'package:chessapp/main_screens/settings_screen.dart';
import 'package:chessapp/providers/game_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MultiProvider(
          providers:[
            ChangeNotifierProvider(create: (_)=> GameProvider())
          ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const HomaScreen(),
      initialRoute: Constants.loginScreen,
      routes: {
        Constants.homeScreen: (context)=>HomaScreen(),
        Constants.gameScreen: (context)=>GameScreen(),
        Constants.settingScreen: (context)=>SettingsScreen(),
        Constants.aboutScreen: (context)=>AboutScreen(),
        Constants.gameTimeScreen: (context)=>GameTimeScreen(),
        Constants.loginScreen:(context)=>LoginScreen(),
        Constants.signUpScreen:(context)=>SignUpScreen(),


      },
    );
  }
}


