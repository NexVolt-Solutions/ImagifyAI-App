import 'dart:io';

import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/models/auth/logout_response.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/forgot_password_response.dart';
import 'package:genwalls/models/auth/register_response.dart';
import 'package:genwalls/models/auth/refresh_response.dart';
import 'package:genwalls/models/auth/verify_response.dart';

class AuthRepository {
  AuthRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<RegisterResponse> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    File? profileImage,
  }) async {
    final fields = <String, String>{
      'username': username,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
    };

    final json = await _apiService.postMultipart(
      path: ApiConstants.register,
      fields: fields,
      file: profileImage,
    );

    return RegisterResponse.fromJson(json);
  }

  Future<VerifyResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    final json = await _apiService.post(
      ApiConstants.verifyEmail,
      body: {
        'email': email,
        'code': code,
      },
    );

    return VerifyResponse.fromJson(json);
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    return LoginResponse.fromJson(json);
  }

  Future<RefreshResponse> refreshToken({
    required String refreshToken,
  }) async {
    final json = await _apiService.post(
      ApiConstants.refresh,
      query: {'refresh_token': refreshToken},
    );

    return RefreshResponse.fromJson(json);
  }

  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    final json = await _apiService.post(
      ApiConstants.forgotPassword,
      body: {
        'email': email,
      },
    );

    return ForgotPasswordResponse.fromJson(json);
  }

  Future<LogoutResponse> signOut({
    required String refreshToken,
  }) async {
    final json = await _apiService.post(
      ApiConstants.signOut,
      query: {'refresh_token': refreshToken},
    );

    return LogoutResponse.fromJson(json);
  }
}

