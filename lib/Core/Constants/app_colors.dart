import 'package:flutter/material.dart';

class AppColors {
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color grayColor = Colors.grey;
  static const Color greenColor = Colors.green;
  static const Color bottomBarColor = Color(0xFF171722);
  static const Color bottomBarIconColor = Color(0xFF6C7278);
  static const Color subTitleColor = Color(0xFFA2A2A2);
  static const Color primeryColor = Color(0xffBA8B02); // Golden color
  static const Color lightPurple = Color(0xFF181818);
  static const Color containerColor = Color(0xFF1A1A1A);
  static const Color textFieldBoderColor = Color(0xFF343434);
  static const Color textFieldIconColor = Color(0xFF6C7278);
  static const Color textFieldSubTitleColor = Color(0xFF6C7278);
  static const Color errorColor = Color(0xFFFF2C2C);
 
  // Light Theme Colors (complementing golden primary)
  static const Color lightBackground = Color(0xFFFFFBF0); // Warm cream/ivory
  static const Color lightSurface = Color(0xFFFFF8E7); // Light golden cream
  static const Color lightContainer = Color(0xFFFFF5D6); // Soft golden tint
  static const Color lightCardBackground = Color(0xFFFFFEF9); // Almost white with warm tint
  static const Color lightTextFieldBackground = Color(0xFFFFF8E7); // Light cream
  static const Color lightTextFieldBorder = Color(0xFFE8D5A3); // Light golden border
  static const Color lightTextPrimary = Color(0xFF2C2416); // Dark brown/charcoal
  static const Color lightTextSecondary = Color(0xFF6B5D3F); // Muted brown
  static const Color lightTextTertiary = Color(0xFF8B7A5A); // Lighter brown
  static const Color lightBottomBar = Color(0xFFFFF8E7); // Light cream
  static const Color lightBottomBarIcon = Color(0xFFB8A082); // Muted golden brown
  static const Color lightDivider = Color(0xFFE8D5A3); // Light golden divider
  static const Color lightGoldenAccent = Color(0xFFD4AF37); // Brighter gold for accents
 
  static const gradient = LinearGradient(
    colors: [primeryColor, lightPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Light theme gradient (golden to warm cream)
  static const gradientLight = LinearGradient(
    colors: [primeryColor, lightGoldenAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
