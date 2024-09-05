import 'package:chessapp/helper/helper_methods.dart';
import 'package:chessapp/service/assets_manager.dart';
import 'package:chessapp/widgets/main_auth_button.dart';
import 'package:chessapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(AssetsManager.chessIcon),
            ),
              Text('Sign In', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,),),

            SizedBox(height: 30,),

              TextFormField(
                decoration: textFormDecoration.copyWith(
                  labelText: 'Enter your Email',
                  hintText: 'Enter your Email',

                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                decoration: textFormDecoration.copyWith(
                  labelText: 'Enter your Password',
                  hintText: 'Enter your Password',
                ),
                obscureText: true,

              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: (){

                }, child: Text('Forgot password?')),
              ),
              SizedBox(height: 10,),
              MainAuthButton(label: 'LOGIN', onPressed: (){
                //login user with email and password
              }, fontSize: 20.0),
              SizedBox(height: 20,),
              Text('- OR -\n Sign in with',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SocialButton(label: 'Guest', height: 55.0, width: 55.0, assetImage: AssetsManager.userIcon, onTap: (){ }),
                 SocialButton(label: 'Google', height: 55.0, width: 55.0, assetImage: AssetsManager.googleIcon, onTap: (){ }),
                  SocialButton(label: 'Facebook', height: 55.0, width: 55.0, assetImage: AssetsManager.facebookIcon, onTap: (){ })

                ],
              ),
              SizedBox(height: 20,),
              HaveAccountWidget(label: 'Don\'t have an account?', labelAction: 'Sign Up', onPressed: (){
                Navigator.pushNamed(context, Constants.signUpScreen);
              })

          ],),
        ),),);
  }
}


