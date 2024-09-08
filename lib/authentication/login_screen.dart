import 'package:chessapp/helper/helper_methods.dart';
import 'package:chessapp/service/assets_manager.dart';
import 'package:chessapp/widgets/main_auth_button.dart';
import 'package:chessapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late String email;
  late String password;
  bool obscuredText = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void signInUser()async{
    final authProvider = context.read<AuthenticatioProvider>();
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();

      UserCredential? userCredential=await authProvider.signInUserWithEmailAndPassword(
          email: email, password: password);

      if(userCredential !=null){
        bool userExist = await authProvider.checkUserExist();
        if(userExist){
          await authProvider.getUserDataFormFirestore();

          await authProvider.saveUserDataToSharedPref();

          await authProvider.setSignedIn();

          formKey.currentState!.reset();

          authProvider.setIsloading(value: false);

          navigate(isSignedIn: true);
        }else{
          //TODO:Navigate to user informacion screen
          navigate(isSignedIn:false);
        }
        print('User created:${userCredential.user!.uid}');
      }

      print('signing up...');
    }else{
      showSnackBar(context: context, content: 'Please fill all fields');
    }
  }

  navigate({required bool isSignedIn}){
    if(isSignedIn){
      Navigator.pushNamedAndRemoveUntil(context, Constants.homeScreen, (route) => false);
    }else{
      //Navigate to user info screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticatioProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter your email';
                      }else if(!validateEmail(value)){
                        return 'Please a valid email';
                      }else if(validateEmail(value)){
                        return null;
                      }
                      return null;
                    },
                    onChanged: (value){
                      email=value.trim();
                    },
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    decoration: textFormDecoration.copyWith(
                      labelText: 'Enter your Password',
                      hintText: 'Enter your Password',

                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          obscuredText=!obscuredText;
                        });
                      }, icon: Icon(obscuredText?Icons.visibility_off:Icons.visibility)),

                    ),
                    obscureText: obscuredText,
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Please enter a password';
                      }else if(value!.length<8){
                        return 'Password must be atleast 8 characters';
                      }
                      return null;
                    },
                    onChanged: (value){
                      password = value;
                    },

                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: (){

                    }, child: Text('Forgot password?')),
                  ),
                  SizedBox(height: 10,),
                  authProvider.isLoading?CircularProgressIndicator():MainAuthButton(label: 'LOGIN', onPressed: (){
                    //login user with email and password
                    signInUser();
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
            ),
          ),
        ),),);
  }
}


