import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/Core/services/token_storage_service.dart';
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
      if (profileImage != null) {
        print('File path: ${profileImage.path}');
        print('File exists: ${profileImage.existsSync()}');
        if (profileImage.existsSync()) {
          print('File size: ${profileImage.lengthSync()} bytes');
        }
      }
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
        print('=== REGISTER API RESPONSE RECEIVED ===');
        print('Response JSON: $json');
        print('Response keys: ${json.keys.toList()}');
        print('Response message: ${json['message']}');
        print('Response status: ${json['status']}');
        print('Response data: ${json['data']}');
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
          print('=== REGISTER RESPONSE PARSED SUCCESSFULLY ===');
          print('Response status: ${response.status}');
          print('Response message: ${response.message}');
          print('Response data: ${response.data}');
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
    required String code,
  }) async {
    // Convert code string to integer to match API spec: {"code": 999999}
    final codeInt = int.tryParse(code) ?? 0;
    
    final json = await _apiService.post(
      ApiConstants.verifyEmail,
      body: {
        'code': codeInt,
      },
    );

    return VerifyResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> resendCode() async {
    final json = await _apiService.post(
      ApiConstants.resendCode,
    );
    return json;
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

  Future<User> getCurrentUser({
    required String accessToken,
    required String userId,
  }) async {
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== GET USER PROFILE API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: GET /api/v1/users/{user_id}');
      print('Has access token: ${accessToken.isNotEmpty}');
      print('User ID: $userId');
    }

    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for GET /api/v1/users/{user_id}',
        statusCode: 400,
      );
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Construct path: /users/{user_id}
    final path = '${ApiConstants.getCurrentUser}/$userId';

    if (kDebugMode) {
      print('--- Request Configuration ---');
      print('Base URL: ${ApiConstants.baseUrl}');
      print('Path: $path');
      print('Full URL: ${ApiConstants.baseUrl}$path');
      print('Method: GET');
      print('Headers: Present');
      print('  - Authorization: Bearer *** (${headers['Authorization']?.length ?? 0} chars)');
      print('  - Token preview (first 30): ${accessToken.substring(0, accessToken.length > 30 ? 30 : accessToken.length)}...');
      print('  - Token preview (last 30): ...${accessToken.substring(accessToken.length > 30 ? accessToken.length - 30 : 0)}');
      print('User ID to use: $userId');
      print('--- Sending Request ---');
    }

    try {
      final json = await _apiService.get(
        path,
        headers: headers,
      );

      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== GET USER PROFILE API: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
        print('Response Status: 200 OK');
        print('Response Type: application/json');
        print('--- Response Data ---');
        print('Full JSON: $json');
        print('Response Keys: ${json.keys.toList()}');
        print('--- User Profile Fields ---');
        print('  id: ${json['id']}');
        print('  username: ${json['username']}');
        print('  email: ${json['email']}');
        print('  first_name: ${json['first_name']}');
        print('  last_name: ${json['last_name']}');
        print('  profile_image_url: ${json['profile_image_url']}');
        print('  is_verified: ${json['is_verified']}');
        print('  is_active: ${json['is_active']}');
        print('  created_at: ${json['created_at']}');
        print('  updated_at: ${json['updated_at']}');
        print('--- Parsing User Model ---');
      }

      final user = User.fromJson(json);

      if (kDebugMode) {
        print('✅ User Model Parsed Successfully');
        print('--- Parsed User Object ---');
        print('  User.id: ${user.id}');
        print('  User.username: ${user.username}');
        print('  User.email: ${user.email}');
        print('  User.fullName: ${user.fullName}');
        print('  User.firstName: ${user.firstName}');
        print('  User.lastName: ${user.lastName}');
        print('  User.profileImageUrl: ${user.profileImageUrl}');
        print('  User.isVerified: ${user.isVerified}');
        print('  User.isActive: ${user.isActive}');
        print('  User.phoneNumber: ${user.phoneNumber}');
        print('  User.createdAt: ${user.createdAt}');
        print('  User.updatedAt: ${user.updatedAt}');
      }

      // Save user_id to SharedPreferences for future use
      if (user.id != null && user.id!.isNotEmpty) {
        try {
          await TokenStorageService.saveUserId(user.id!);
          if (kDebugMode) {
            print('✅ User ID saved to storage: ${user.id}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  Failed to save user_id: $e');
          }
        }
      }

      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== GET USER PROFILE API: END (SUCCESS) ===');
        print('═══════════════════════════════════════════════════════════');
      }

      return user;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('═══════════════════════════════════════════════════════════');
        print('=== GET USER PROFILE API: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
        print('Exception Type: ${e.runtimeType}');
        print('Exception Message: $e');
        if (e is ApiException) {
          print('Status Code: ${e.statusCode}');
          print('Error Details:');
          print('  - The API endpoint requires: GET /api/v1/users/{user_id}');
          print('  - Current request path: $path');
          if (e.statusCode == 403) {
            print('  - 403 Forbidden: Unauthorized access');
            print('  - Possible reasons:');
          
            print('    2. user_id is required but not provided');
            print('    3. Token is invalid or expired');
            print('    4. User does not have permission to access this resource');
          } else if (e.statusCode == 404) {
            print('  - 404 Not Found: Endpoint does not exist');
            print('  - The path "$path" is not available on the server');
          } else if (e.statusCode == 401) {
            print('  - 401 Unauthorized: Token is invalid or expired');
            print('  - Need to refresh token or re-login');
          }
        }
        print('--- Stack Trace ---');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
        print('=== GET USER PROFILE API: END (ERROR) ===');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  Future<UpdateUserResponse> updateUser({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? username,
    required String accessToken,
    required String userId,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for updating user profile',
        statusCode: 400,
      );
    }
    
    // Construct path: /users/{user_id}
    final path = '${ApiConstants.updateUser}/$userId';

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
      path,
      headers: headers,
      body: body.isNotEmpty ? body : null,
    );

    return UpdateUserResponse.fromJson(json);
  }

  // Update Username & Profile Image (multipart/form-data)
  // According to docs: PUT /users/{user_id}/profile
  Future<UpdateUserResponse> updateUserProfile({
    String? username,
    File? profileImage,
    required String accessToken,
    required String userId,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for updating user profile',
        statusCode: 400,
      );
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};
    
    // Construct path: /users/{user_id}/profile
    final path = '${ApiConstants.updateUserProfile}/$userId/profile';

    final fields = <String, String>{};
    if (username != null && username.isNotEmpty) {
      fields['username'] = username;
    }

    final json = await _apiService.putMultipart(
      path: path,
      file: profileImage,
      fileFieldName: 'profile_image',
      headers: headers,
    );

    return UpdateUserResponse.fromJson(json);
  }

  Future<UpdateProfilePictureResponse> updateProfilePicture({
    required File profileImage,
    required String accessToken,
    required String userId,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for updating profile picture',
        statusCode: 400,
      );
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};
    
    // Construct path: /users/{user_id}/profile (as per updated API docs)
    final path = '${ApiConstants.updateUserProfile}/$userId/profile';

    final json = await _apiService.putMultipart(
      path: path,
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
    required String accessToken,
    required String userId,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for updating password',
        statusCode: 400,
      );
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};
    
    // Construct path: /users/{user_id}/password
    final path = '${ApiConstants.updatePassword}/$userId/password';

    final json = await _apiService.put(
      path,
      headers: headers,
      body: {
        'old_password': oldPassword,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );

    return UpdatePasswordResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> verifyForgotOtp({
    required String code,
  }) async {
    final json = await _apiService.post(
      ApiConstants.verifyForgotOtp,
      body: {
        'code': code,
      },
    );
    return json;
  }

  Future<Map<String, dynamic>> setNewPassword({
    required String password,
    required String confirmPassword,
  }) async {
    final json = await _apiService.post(
      ApiConstants.setNewPassword,
      body: {
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
    return json;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String oldPassword,
    required String password,
    required String confirmPassword,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    final json = await _apiService.post(
      ApiConstants.resetPassword,
      headers: headers,
      body: {
        'old_password': oldPassword,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
    return json;
  }

  Future<LoginResponse> googleSignIn({
    required String idToken,
    required String name,
    String? picture,
  }) async {
    final body = <String, dynamic>{
      'id_token': idToken,
      'name': name,
    };
    if (picture != null && picture.isNotEmpty) {
      body['picture'] = picture;
    }

    final json = await _apiService.post(
      ApiConstants.googleSignIn,
      body: body,
    );

    return LoginResponse.fromJson(json);
  }

  Future<void> deleteAccount({
    required String userId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }
    
    if (userId.isEmpty) {
      throw ApiException('User ID is required', statusCode: 400);
    }
    
    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Use /users/{user_id} as per API docs
    await _apiService.delete(
      '/users/$userId',
      headers: headers,
    );
  }
}

