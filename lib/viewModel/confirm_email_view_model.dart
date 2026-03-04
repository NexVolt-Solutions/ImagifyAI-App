import 'package:flutter/material.dart';
import 'package:imagifyai/Core/utils/Routes/routes_name.dart';

/// ViewModel for the Confirm Email (forgot flow) screen. Holds email state and navigation.
class ConfirmEmailViewModel extends ChangeNotifier {
  final emailController = TextEditingController();

  void navigateToForgotVerification(BuildContext context) {
    final email = emailController.text.trim();
    Navigator.pushNamed(
      context,
      RoutesName.ForgotVerificationScreen,
      arguments: email.isNotEmpty ? email : null,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
