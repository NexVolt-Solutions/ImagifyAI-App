import 'dart:io';

import 'package:imagifyai/models/auth/forgot_password_response.dart';
import 'package:imagifyai/models/auth/login_response.dart';
import 'package:imagifyai/models/auth/logout_response.dart';
import 'package:imagifyai/models/auth/refresh_response.dart';
import 'package:imagifyai/models/auth/register_response.dart';
import 'package:imagifyai/models/auth/verify_response.dart';
import 'package:imagifyai/models/user/update_password_response.dart';
import 'package:imagifyai/models/user/update_profile_picture_response.dart';
import 'package:imagifyai/models/user/update_user_response.dart';
import 'package:imagifyai/models/user/user.dart';

/// Domain contract for auth and user operations.
/// Implemented by [AuthRepository] in the data layer.
abstract class IAuthRepository {
  Future<RegisterResponse> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    File? profileImage,
  });

  Future<VerifyResponse> verifyEmail({required String code});

  Future<Map<String, dynamic>> resendCode();

  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<RefreshResponse> refreshToken({required String refreshToken});

  Future<ForgotPasswordResponse> forgotPassword({required String email});

  Future<LogoutResponse> signOut({required String refreshToken});

  Future<User> getCurrentUser({
    required String accessToken,
    required String userId,
    bool forceRefresh = false,
  });

  Future<UpdateUserResponse> updateUser({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? username,
    required String accessToken,
    required String userId,
  });

  Future<UpdateUserResponse> updateUserProfile({
    String? username,
    File? profileImage,
    required String accessToken,
    required String userId,
  });

  Future<UpdateProfilePictureResponse> updateProfilePicture({
    required File profileImage,
    required String accessToken,
    required String userId,
  });

  Future<UpdatePasswordResponse> updatePassword({
    required String oldPassword,
    required String password,
    required String confirmPassword,
    required String accessToken,
    required String userId,
  });

  Future<Map<String, dynamic>> verifyForgotOtp({required String code});

  Future<Map<String, dynamic>> setNewPassword({
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<Map<String, dynamic>> resetPassword({
    required String oldPassword,
    required String password,
    required String confirmPassword,
    required String accessToken,
  });

  Future<LoginResponse> googleSignIn({
    required String idToken,
    required String name,
    String? picture,
  });

  Future<void> deleteAccount({
    required String userId,
    required String accessToken,
  });
}
