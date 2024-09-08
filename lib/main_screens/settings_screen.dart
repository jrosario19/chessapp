import 'package:chessapp/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(onPressed: (){
            context.read<AuthenticatioProvider>().signOutUser().whenComplete((){
              Navigator.pushNamedAndRemoveUntil(context, Constants.loginScreen, (route) => false);
            });

          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
