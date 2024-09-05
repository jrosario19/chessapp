import 'package:flutter/material.dart';

class MainAuthButton extends StatelessWidget {
  const MainAuthButton({Key? key, required this.label, required this.onPressed, required this.fontSize}) : super(key: key);

  final String label;
  final Function() onPressed;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Colors.blue,
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.infinity,
        child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),),
      ),
    );
  }
}
