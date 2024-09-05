import 'package:flutter/material.dart';

import '../helper/helper_methods.dart';
import '../service/assets_manager.dart';
import '../widgets/main_auth_button.dart';
import '../widgets/social_button.dart';
import '../widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Text('Sign Up', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,),),
              SizedBox(height: 20,),
              Stack(children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              backgroundImage: AssetImage(AssetsManager.userIcon ),
            ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.lightBlue,
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(35)),
                      
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IconButton(icon: Icon(Icons.camera_alt, color: Colors.white,),
                        onPressed: (){
                          //pick image from camera or galery
                        },),
                      ),
                    ))
          ],),
          SizedBox(height: 40,),
          TextFormField(
            decoration: textFormDecoration.copyWith(
              labelText: 'Enter your name',
              hintText: 'Enter your name',

            )),
              SizedBox(height: 20,),
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

              SizedBox(height: 20,),
              MainAuthButton(label: 'SIGN UP', onPressed: (){
                //login user with email and password
              }, fontSize: 20.0),

              SizedBox(height: 20,),

              SizedBox(height: 20,),
              HaveAccountWidget(label: 'Have an account?', labelAction: 'Sign In', onPressed: (){
                Navigator.pop(context);
              })

            ],),
        ),),);;
  }
}
