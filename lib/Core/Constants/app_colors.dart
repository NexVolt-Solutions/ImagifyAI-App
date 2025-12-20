import 'package:flutter/material.dart';

class AppColors {
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color grayColor = Colors.grey;
  static const Color greenColor = Colors.green;
  static const Color bottomBarColor = Color(0xFF171722);
  static const Color bottomBarIconColor = Color(0xFF6C7278);

  static const Color subTitleColor = Color(0xFFA2A2A2);
  static const Color primeryColor = Color(0xFF9F56FE);
  static const Color lightPurple = Color(0xFFD4B3FF);
  static const Color containerColor = Color(0xFF1A1A1A);
  static const Color textFieldBoderColor = Color(0xFF343434);
  static const Color textFieldIconColor = Color(0xFF6C7278);
  static const Color textFieldSubTitleColor = Color(0xFF6C7278);
  static const Color errorColor = Color(0xFFFF2C2C);
  static const Color gridButtonColor = Color(0xFF1F75FE);

  static const gradient = LinearGradient(
    colors: [primeryColor, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
