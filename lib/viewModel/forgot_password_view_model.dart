import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  int selectedIndex = -1;

  final List<String> items = [
    "1 or more numbers (0-9)",
    "1 or more English letters (A-Z, a,z)",
    "7 or more charactrers",
  ];
}
