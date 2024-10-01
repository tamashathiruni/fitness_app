import 'package:flutter/material.dart';

class AppColors{
  static const primaryColor1 =  Color.fromARGB(255, 0, 42, 255);
  static const primaryColor2 =  Color.fromARGB(255, 0, 128, 255);

  static const secondaryColor1 =  Color.fromARGB(255, 0, 196, 33);
  static const secondaryColor2 =  Color.fromARGB(255, 72, 151, 54);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF1D1617);
  static const grayColor = Color(0xFF7B6F72);
  static const lightGrayColor = Color(0xFFF7F8F8);
  static const midGrayColor = Color(0xFFADA4A5);

  static List<Color> get primaryG => [primaryColor1,primaryColor2];
  static List<Color> get secondaryG => [secondaryColor1,secondaryColor2];
}