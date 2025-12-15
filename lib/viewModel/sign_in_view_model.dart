import 'package:flutter/material.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/utils/Routes/routes_name.dart';
import 'package:genwalls/Core/utils/snackbar_util.dart';
import 'package:genwalls/models/auth/logout_response.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/refresh_response.dart';
import 'package:genwalls/repositories/auth_repository.dart';

class SignInViewModel extends ChangeNotifier {
  SignInViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool rememberMe = true;
  String? _refreshToken;
  String? _accessToken;

  void toggleRemember(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (isLoading) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      _showMessage(context, 'Password is required');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final LoginResponse response = await _authRepository.login(
        email: email,
        password: password,
      );

      final message = response.message ?? 'Logged in successfully';
      _refreshToken = response.refreshToken;
      _accessToken = response.accessToken;
      _showMessage(context, message, isError: false);
      Navigator.pushNamed(context, RoutesName.BottomNavScreen);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSession(BuildContext context) async {
    if (isLoading) return;
    if ((_refreshToken ?? '').isEmpty) {
      _showMessage(context, 'No refresh token available. Please login again.');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final RefreshResponse response = await _authRepository.refreshToken(
        refreshToken: _refreshToken!,
      );
      _refreshToken = response.refreshToken ?? _refreshToken;
      _accessToken = response.accessToken ?? _accessToken;
      final message = response.message ?? 'Session refreshed';
      _showMessage(context, message, isError: false);
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    if (isLoading) return;
    if ((_refreshToken ?? '').isEmpty) {
      _showMessage(context, 'No refresh token available. Please login again.');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final LogoutResponse response =
          await _authRepository.signOut(refreshToken: _refreshToken!);
      final message = response.message ?? 'Logged out successfully';
      _showMessage(context, message, isError: false);
      _refreshToken = null;
      _accessToken = null;
      emailController.clear();
      passwordController.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.SignInScreen,
        (route) => false,
      );
    } on ApiException catch (e) {
      errorMessage = e.message;
      _showMessage(context, e.message);
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      _showMessage(context, errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = true}) {
    SnackbarUtil.showTopSnackBar(context, message, isError: isError);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
