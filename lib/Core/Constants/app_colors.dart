import 'package:flutter/material.dart';

class AppColors {
  static const Color appMainColor = Color(0xFF756EA9);
  static const Color lightPurple = Color(0xFFD5B4FF); // #D5B4FF

  static const gradient = LinearGradient(
    colors: [appMainColor, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
