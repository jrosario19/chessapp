import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget{
  const SocialButton(
      {super.key, required this.label, required this.height, required this.width, required this.assetImage, required this.onTap}
      );

  final String label;
  final String assetImage;
  final double height;
  final double width;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0,2),
                      blurRadius: 6.0
                  )
                ],
                image: DecorationImage(
                    image: AssetImage(assetImage)
                )
            ),

          ),
          SizedBox(height: 5,),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),)
        ],
      ),
    );
  }
}