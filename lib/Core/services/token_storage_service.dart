import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imagifyai/models/user/user.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _userDataKey = 'user_data';

  /// Save access token to SharedPreferences
  static Future<bool> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_accessTokenKey, token);
    } catch (e) {
      return false;
    }
  }

  /// Save refresh token to SharedPreferences
  static Future<bool> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      return false;
    }
  }

  /// Save both tokens
  static Future<bool> saveTokens(String accessToken, String refreshToken) async {
    try {
      // Add a small delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final accessSaved = await prefs.setString(_accessTokenKey, accessToken);
      final refreshSaved = await prefs.setString(_refreshTokenKey, refreshToken);
      return accessSaved && refreshSaved;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        final accessSaved = await prefs.setString(_accessTokenKey, accessToken);
        final refreshSaved = await prefs.setString(_refreshTokenKey, refreshToken);
        return accessSaved && refreshSaved;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get access token from SharedPreferences
  static Future<String?> getAccessToken() async {
    try {
      // Add a small delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);
      return token;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_accessTokenKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Get refresh token from SharedPreferences
  static Future<String?> getRefreshToken() async {
    try {
      // Add a small delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_refreshTokenKey);
      return token;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_refreshTokenKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Check if user is logged in (has tokens)
  static Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Save user_id to SharedPreferences
  static Future<bool> saveUserId(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_userIdKey, userId);
      return saved;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(_userIdKey, userId);
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get user_id from SharedPreferences
  static Future<String?> getUserId() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_userIdKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Save user data to SharedPreferences
  static Future<bool> saveUserData(User user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      return await prefs.setString(_userDataKey, userJson);
    } catch (e) {
      return false;
    }
  }

  /// Get user data from SharedPreferences
  static Future<User?> getUserData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userDataKey);
      
      if (userJsonString == null || userJsonString.isEmpty) {
        return null;
      }
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data from SharedPreferences
  static Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userDataKey);
    } catch (e) {
      return false;
    }
  }

  /// Clear all tokens (logout)
  /// Note: This does NOT clear remembered email - that's handled separately
  static Future<bool> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessRemoved = await prefs.remove(_accessTokenKey);
      final refreshRemoved = await prefs.remove(_refreshTokenKey);
      final userIdRemoved = await prefs.remove(_userIdKey);
      final userDataRemoved = await prefs.remove(_userDataKey);
      return accessRemoved && refreshRemoved && userIdRemoved && userDataRemoved;
    } catch (e) {
      return false;
    }
  }

  /// Save onboarding completion status
  static Future<bool> setOnboardingCompleted(bool completed) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_onboardingCompletedKey, completed);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setBool(_onboardingCompletedKey, completed);
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return prefs.getBool(_onboardingCompletedKey) ?? false;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Save remembered email for "Remember Me" functionality
  static Future<bool> saveRememberedEmail(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_rememberedEmailKey, email);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return await prefs.setString(_rememberedEmailKey, email);
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get remembered email for "Remember Me" functionality
  static Future<String?> getRememberedEmail() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_rememberedEmailKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_rememberedEmailKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Clear remembered email
  static Future<bool> clearRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_rememberedEmailKey);
    } catch (e) {
      return false;
    }
  }
}

