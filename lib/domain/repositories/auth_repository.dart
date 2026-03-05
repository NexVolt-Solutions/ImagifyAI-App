import 'dart:io';

import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/models/auth/logout_response.dart';
import 'package:imagifyai/models/auth/login_response.dart';
import 'package:imagifyai/models/auth/forgot_password_response.dart';
import 'package:imagifyai/models/auth/register_response.dart';
import 'package:imagifyai/models/auth/refresh_response.dart';
import 'package:imagifyai/models/auth/verify_response.dart';
import 'package:imagifyai/models/user/user.dart';
import 'package:imagifyai/models/user/update_user_response.dart';
import 'package:imagifyai/models/user/update_profile_picture_response.dart';
import 'package:imagifyai/models/user/update_password_response.dart';
import 'package:imagifyai/domain/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  @override
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

    try {
      final json = await _apiService.postMultipart(
        path: ApiConstants.register,
        fields: fields,
        file: profileImage,
      );

      if (json.isEmpty) {
        throw ApiException('Empty response from server');
      }

      try {
        final response = RegisterResponse.fromJson(json);
        return response;
      } catch (e) {
        // If parsing fails, check if there's an error message in the response
        final errorMsg =
            json['message']?.toString() ??
            json['error']?.toString() ??
            'Failed to parse registration response';
        throw ApiException(errorMsg);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<VerifyResponse> verifyEmail({required String code}) async {
    // Convert code string to integer to match API spec: {"code": 999999}
    final codeInt = int.tryParse(code) ?? 0;

    final json = await _apiService.post(
      ApiConstants.verifyEmail,
      body: {'code': codeInt},
    );

    return VerifyResponse.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> resendCode() async {
    final json = await _apiService.post(ApiConstants.resendCode);
    return json;
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _apiService.post(
      ApiConstants.login,
      body: {'email': email, 'password': password},
    );

    return LoginResponse.fromJson(json);
  }

  @override
  Future<RefreshResponse> refreshToken({required String refreshToken}) async {
    final json = await _apiService.post(
      ApiConstants.refresh,
      query: {'refresh_token': refreshToken},
    );

    return RefreshResponse.fromJson(json);
  }

  @override
  Future<ForgotPasswordResponse> forgotPassword({required String email}) async {
    final json = await _apiService.post(
      ApiConstants.forgotPassword,
      body: {'email': email},
    );

    return ForgotPasswordResponse.fromJson(json);
  }

  @override
  Future<LogoutResponse> signOut({required String refreshToken}) async {
    final json = await _apiService.post(
      ApiConstants.signOut,
      query: {'refresh_token': refreshToken},
    );

    return LogoutResponse.fromJson(json);
  }

  @override
  Future<User> getCurrentUser({
    required String accessToken,
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (userId.isEmpty) {
      throw ApiException(
        'User ID is required for GET /api/v1/users/{user_id}',
        statusCode: 400,
      );
    }

    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      try {
        final cachedUser = await TokenStorageService.getUserData();
        if (cachedUser != null && cachedUser.id == userId) {
          return cachedUser;
        }
      } catch (e) {
        // Proceed with API call
      }
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Construct path: /users/{user_id}
    final path = '${ApiConstants.getCurrentUser}/$userId';

    try {
      final json = await _apiService.get(path, headers: headers);
      final user = User.fromJson(json);

      if (user.id != null && user.id!.isNotEmpty) {
        try {
          await TokenStorageService.saveUserId(user.id!);
        } catch (e) {
          // ignore
        }
      }

      try {
        await TokenStorageService.saveUserData(user);
      } catch (e) {
        // ignore
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
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

    final json = await _apiService.patch(path, headers: headers, body: body);
    return UpdateUserResponse.fromJson(json);
  }

  // Update Username & Profile Image (multipart/form-data)
  // According to docs: PUT /users/{user_id}/profile
  @override
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

    // Username should be sent as a query parameter, not in multipart form
    final query = <String, String>{};
    if (username != null && username.isNotEmpty) {
      query['username'] = username;
    }

    final json = await _apiService.putMultipart(
      path: path,
      file: profileImage,
      fileFieldName: 'profile_image',
      headers: headers,
      query: query.isNotEmpty ? query : null,
    );

    return UpdateUserResponse.fromJson(json);
  }

  @override
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

  @override
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

    final json = await _apiService.patch(
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

  @override
  Future<Map<String, dynamic>> verifyForgotOtp({required String code}) async {
    final json = await _apiService.post(
      ApiConstants.verifyForgotOtp,
      body: {'code': code},
    );
    return json;
  }

  @override
  Future<Map<String, dynamic>> setNewPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final json = await _apiService.post(
      ApiConstants.setNewPassword,
      body: {
        'password': password,
        'confirm_password': confirmPassword,
        'email': email,
      },
    );
    return json;
  }

  @override
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

  @override
  Future<LoginResponse> googleSignIn({
    required String idToken,
    required String name,
    String? picture,
  }) async {
    final body = <String, dynamic>{'id_token': idToken, 'name': name};
    if (picture != null && picture.isNotEmpty) {
      body['picture'] = picture;
    }

    final json = await _apiService.post(ApiConstants.googleSignIn, body: body);

    return LoginResponse.fromJson(json);
  }

  @override
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
    await _apiService.delete('/users/$userId', headers: headers);
  }
}
