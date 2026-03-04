import 'package:flutter/material.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';

/// ViewModel for the Account Created (success) screen. Holds navigation logic only.
class AccountCreatedViewModel extends ChangeNotifier {
  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  void navigateToSignIn(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesName.SignInScreen,
      (route) => false,
    );
  }
}
