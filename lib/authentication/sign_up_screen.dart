
import 'dart:io';

import 'package:chessapp/constants.dart';
import 'package:chessapp/models/user_model.dart';
import 'package:chessapp/providers/authentication_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

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
  File? finalFileImage;
  String fileImageURL='';
  late String name;
  late String email;
  late String password;
  bool obscuredText = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();


  void selectImage({required bool fromCamera})async{
    finalFileImage= await pickImage(fromCamera: fromCamera, onFail: (e){
      showSnackBar(context: context, content: e.toString());
    });
    if(finalFileImage!=null){
      cropImage(finalFileImage!.path);
    }else{
      popCropDialog();
    }
  }

  void cropImage(String path) async{
      CroppedFile? croppedFile= await ImageCropper().cropImage(sourcePath:  path, maxHeight: 800, maxWidth: 800);
      popCropDialog();
      if(croppedFile!=null){
        setState(() {
          finalFileImage=File(croppedFile!.path);
        });
      }else{
        popCropDialog();
      }

  }

  void popCropDialog(){
    Navigator.pop(context);
  }

  void showImagePickerDialog(){
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Select an option'),
            content: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: (){
                    selectImage(fromCamera: true);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Gallery'),
                  onTap: (){
                    selectImage(fromCamera: false);
                  },
                )
              ],
              mainAxisSize: MainAxisSize.min,
            ),
          );
        });
  }

  void signUoUser()async{
    final authProvider = context.read<AuthenticatioProvider>();
    if(formKey.currentState!.validate()){
      formKey.currentState!.save();

      UserCredential? userCredential=await authProvider.createUserWithEmailAndPassword(
          email: email, password: password);

      if(userCredential !=null){
        UserModel userModel = UserModel(
            uid: userCredential.user!.uid,
            name: name,
            email: email,
            image: '',
            createdAt: '',
        playerRating: 1200);
        authProvider.saveUserDataToFireStore(
            currentUser: userModel,
            fileImage: finalFileImage,
            onSuccess: ()async{
              formKey.currentState!.reset();

              showSnackBar(context: context, content: 'Sign Up successful, please Login');

               await authProvider.signOutUser().whenComplete((){
                 Navigator.pop(context);
               });

            },
            onFail: (error){
              showSnackBar(context: context, content: error.toString());
            });
        print('User created:${userCredential.user!.uid}');
      }

      print('signing up...');
    }else{
      showSnackBar(context: context, content: 'Please fill all fields');
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
                 Text('Sign Up', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold,),),
                  SizedBox(height: 20,),
                  finalFileImage != null?Stack(children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue,
                      backgroundImage: FileImage(File(finalFileImage!.path)),
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
                                showImagePickerDialog();
                              },),
                          ),
                        ))
                  ],):
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
                              showImagePickerDialog();
                            },),
                          ),
                        ))
              ],),
              SizedBox(height: 40,),
              TextFormField(
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: 25,
                maxLines: 1,
                decoration: textFormDecoration.copyWith(
                  counterText: '',
                  labelText: 'Enter your name',
                  hintText: 'Enter your name',

                ),
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please enter your name';
                  }else if(value!.length<3){
                    return 'Name must be atleast 3 characters';
                  }
                  return null;
                },
                onChanged: (value){
                  name=value.trim();
                },),
                  SizedBox(height: 20,),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
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
                    textInputAction: TextInputAction.done,
                      decoration: textFormDecoration.copyWith(
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            obscuredText=!obscuredText;
                          });
                        }, icon: Icon(obscuredText?Icons.visibility_off:Icons.visibility)),
                        labelText: 'Enter your Password',
                        hintText: 'Enter your Password',
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

                  SizedBox(height: 20,),

                  authProvider.isLoading?CircularProgressIndicator(): MainAuthButton(label: 'SIGN UP', onPressed: (){
                    //login user with email and password
                    signUoUser();
                  }, fontSize: 20.0),

                  SizedBox(height: 20,),

                  SizedBox(height: 20,),
                  HaveAccountWidget(label: 'Have an account?', labelAction: 'Sign In', onPressed: (){
                    Navigator.pop(context);
                  })

                ],),
            ),
          ),
        ),),);;
  }


}
