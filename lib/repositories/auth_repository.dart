import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/models/auth/logout_response.dart';
import 'package:genwalls/models/auth/login_response.dart';
import 'package:genwalls/models/auth/forgot_password_response.dart';
import 'package:genwalls/models/auth/register_response.dart';
import 'package:genwalls/models/auth/refresh_response.dart';
import 'package:genwalls/models/auth/verify_response.dart';
import 'package:genwalls/models/user/user.dart';
import 'package:genwalls/models/user/update_user_response.dart';
import 'package:genwalls/models/user/update_profile_picture_response.dart';
import 'package:genwalls/models/user/update_password_response.dart';

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

    if (kDebugMode) {
      print('=== AUTH REPOSITORY: REGISTER ===');
      print('Endpoint: ${ApiConstants.baseUrl}${ApiConstants.register}');
      print('Fields: $fields');
      print('Has file: ${profileImage != null}');
    }

    try {
      if (kDebugMode) {
        print('Calling _apiService.postMultipart...');
      }
      
      final json = await _apiService.postMultipart(
        path: ApiConstants.register,
        fields: fields,
        file: profileImage,
      );

      if (kDebugMode) {
        print('=== API RESPONSE RECEIVED ===');
        print('Response JSON: $json');
        print('Response keys: ${json.keys.toList()}');
      }

      // Validate JSON structure before parsing
      if (json.isEmpty) {
        if (kDebugMode) {
          print('ERROR: Empty response from server');
        }
        throw ApiException('Empty response from server');
      }

      try {
        if (kDebugMode) {
          print('Parsing RegisterResponse from JSON...');
        }
        final response = RegisterResponse.fromJson(json);
        if (kDebugMode) {
          print('RegisterResponse parsed successfully');
          print('Status: ${response.status}');
          print('Message: ${response.message}');
        }
        return response;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('=== ERROR PARSING RegisterResponse ===');
          print('Exception: $e');
          print('Stack trace: $stackTrace');
          print('JSON that failed to parse: $json');
        }
        // If parsing fails, check if there's an error message in the response
        final errorMsg = json['message']?.toString() ?? 
                        json['error']?.toString() ?? 
                        'Failed to parse registration response';
        throw ApiException(errorMsg);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR IN AUTH REPOSITORY REGISTER ===');
        print('Exception type: ${e.runtimeType}');
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
      
      // Re-throw ApiException as-is
      if (e is ApiException) {
        if (kDebugMode) {
          print('Re-throwing ApiException: ${e.message}');
        }
        rethrow;
      }
      
      // Wrap other exceptions with more context
      if (kDebugMode) {
        print('Wrapping exception as ApiException');
      }
      throw ApiException(
        'Registration failed: ${e.toString()}',
      );
    }
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

  Future<User> getCurrentUser({String? accessToken}) async {
    final headers = accessToken != null && accessToken.isNotEmpty
        ? <String, String>{'Authorization': 'Bearer $accessToken'}
        : null;

    final json = await _apiService.get(
      ApiConstants.getCurrentUser,
      headers: headers,
    );

    return User.fromJson(json);
  }

  Future<UpdateUserResponse> updateUser({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? username,
    String? accessToken,
  }) async {
    final headers = accessToken != null && accessToken.isNotEmpty
        ? <String, String>{'Authorization': 'Bearer $accessToken'}
        : null;

    final body = <String, String>{};
    if (firstName != null && firstName.isNotEmpty) {
      body['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      body['last_name'] = lastName;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phone_number'] = phoneNumber;
    }
    if (username != null && username.isNotEmpty) {
      body['username'] = username;
    }

    final json = await _apiService.put(
      ApiConstants.updateUser,
      headers: headers,
      body: body.isNotEmpty ? body : null,
    );

    return UpdateUserResponse.fromJson(json);
  }

  Future<UpdateProfilePictureResponse> updateProfilePicture({
    required File profileImage,
    String? accessToken,
  }) async {
    final headers = accessToken != null && accessToken.isNotEmpty
        ? <String, String>{'Authorization': 'Bearer $accessToken'}
        : null;

    final json = await _apiService.putMultipart(
      path: ApiConstants.updateProfilePicture,
      file: profileImage,
      fileFieldName: 'profile_image',
      headers: headers,
    );

    return UpdateProfilePictureResponse.fromJson(json);
  }

  Future<UpdatePasswordResponse> updatePassword({
    required String oldPassword,
    required String password,
    required String confirmPassword,
    String? accessToken,
  }) async {
    final headers = accessToken != null && accessToken.isNotEmpty
        ? <String, String>{'Authorization': 'Bearer $accessToken'}
        : null;

    final json = await _apiService.put(
      ApiConstants.updatePassword,
      headers: headers,
      body: {
        'old_password': oldPassword,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );

    return UpdatePasswordResponse.fromJson(json);
  }
}

