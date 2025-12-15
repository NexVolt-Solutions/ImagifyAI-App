import 'dart:io';

import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/models/auth/register_response.dart';

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
}

