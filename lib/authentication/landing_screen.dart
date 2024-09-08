import 'package:chessapp/constants.dart';
import 'package:chessapp/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/assets_manager.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {

  void checkAuthenticationState()async{
    final authProvider = context.read<AuthenticatioProvider>();
    if(await authProvider.checkIsSignedIn()){
      await authProvider.getUserDataFormFirestore();

      await authProvider.saveUserDataToSharedPref();

      navigate(isSignedIn: true);
    }else{
      navigate(isSignedIn: false);
    }
  }

  @override
  void initState() {
    checkAuthenticationState();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(AssetsManager.chessIcon),
      ),),
    );
  }

  void navigate({required bool isSignedIn}) {
    if(isSignedIn){
      Navigator.pushReplacementNamed(context, Constants.homeScreen);
    }else{
      Navigator.pushReplacementNamed(context, Constants.loginScreen);
    }
  }
}
