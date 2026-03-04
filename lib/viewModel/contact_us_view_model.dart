import 'package:flutter/material.dart';

class ContactUsViewModel extends ChangeNotifier {
  int selectedSubjectIndex = 0;

  void setSelectedSubjectIndex(int index) {
    if (selectedSubjectIndex == index) return;
    selectedSubjectIndex = index;
    notifyListeners();
  }
}
