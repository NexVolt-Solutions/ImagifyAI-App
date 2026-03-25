import 'dart:convert';
import 'package:imagifyai/Core/services/secure_storage_helper.dart';
import 'package:imagifyai/models/user/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'imagifyai.access_token';
  static const String _refreshTokenKey = 'imagifyai.refresh_token';
  static const String _userIdKey = 'imagifyai.user_id';
  static const String _onboardingCompletedKey = 'imagifyai.onboarding_completed';
  static const String _rememberedEmailKey = 'imagifyai.remembered_email';
  static const String _userDataKey = 'imagifyai.user_data';

  static const String _legacyAccessTokenKey = 'access_token';
  static const String _legacyRefreshTokenKey = 'refresh_token';
  static const String _legacyUserIdKey = 'user_id';
  static const String _legacyOnboardingKey = 'onboarding_completed';
  static const String _legacyRememberedEmailKey = 'remembered_email';
  static const String _legacyUserDataKey = 'user_data';

  static Future<void>? _migrationFuture;

  static Future<void> _ensureMigratedFromSharedPreferences() async {
    _migrationFuture ??= _runSharedPreferencesMigration();
    await _migrationFuture;
  }

  static Future<void> _runSharedPreferencesMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Future<void> migrateString(String legacyKey, String secureKey) async {
        final current = await SecureStorageHelper.read(secureKey);
        if (current != null && current.isNotEmpty) {
          if (prefs.containsKey(legacyKey)) await prefs.remove(legacyKey);
          return;
        }
        final legacy = prefs.getString(legacyKey);
        if (legacy != null && legacy.isNotEmpty) {
          await SecureStorageHelper.write(secureKey, legacy);
        }
        if (prefs.containsKey(legacyKey)) await prefs.remove(legacyKey);
      }

      await migrateString(_legacyAccessTokenKey, _accessTokenKey);
      await migrateString(_legacyRefreshTokenKey, _refreshTokenKey);
      await migrateString(_legacyUserIdKey, _userIdKey);
      await migrateString(_legacyRememberedEmailKey, _rememberedEmailKey);
      await migrateString(_legacyUserDataKey, _userDataKey);

      if (await SecureStorageHelper.read(_onboardingCompletedKey) == null &&
          prefs.containsKey(_legacyOnboardingKey)) {
        await SecureStorageHelper.writeBool(
          _onboardingCompletedKey,
          prefs.getBool(_legacyOnboardingKey) ?? false,
        );
      }
      if (prefs.containsKey(_legacyOnboardingKey)) {
        await prefs.remove(_legacyOnboardingKey);
      }
    } catch (_) {}
  }

  static Future<void> _removeLegacySharedPreferenceKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legacyAccessTokenKey);
      await prefs.remove(_legacyRefreshTokenKey);
      await prefs.remove(_legacyUserIdKey);
      await prefs.remove(_legacyOnboardingKey);
      await prefs.remove(_legacyRememberedEmailKey);
      await prefs.remove(_legacyUserDataKey);
    } catch (_) {}
  }

  /// Save access token
  static Future<bool> saveAccessToken(String token) async {
    try {
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.write(_accessTokenKey, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save refresh token
  static Future<bool> saveRefreshToken(String token) async {
    try {
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.write(_refreshTokenKey, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save both tokens
  static Future<bool> saveTokens(String accessToken, String refreshToken) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.write(_accessTokenKey, accessToken);
      await SecureStorageHelper.write(_refreshTokenKey, refreshToken);
      return true;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        await SecureStorageHelper.write(_accessTokenKey, accessToken);
        await SecureStorageHelper.write(_refreshTokenKey, refreshToken);
        return true;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      return SecureStorageHelper.read(_accessTokenKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        return SecureStorageHelper.read(_accessTokenKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      return SecureStorageHelper.read(_refreshTokenKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        return SecureStorageHelper.read(_refreshTokenKey);
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

  /// Save user_id
  static Future<bool> saveUserId(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.write(_userIdKey, userId);
      return true;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        await SecureStorageHelper.write(_userIdKey, userId);
        return true;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get user_id
  static Future<String?> getUserId() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      return SecureStorageHelper.read(_userIdKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        return SecureStorageHelper.read(_userIdKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Save user data
  static Future<bool> saveUserData(User user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      final userJson = jsonEncode(user.toJson());
      await SecureStorageHelper.write(_userDataKey, userJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user data
  static Future<User?> getUserData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      final userJsonString = await SecureStorageHelper.read(_userDataKey);

      if (userJsonString == null || userJsonString.isEmpty) {
        return null;
      }
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      return User.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data
  static Future<bool> clearUserData() async {
    try {
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.delete(_userDataKey);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_legacyUserDataKey);
      } catch (_) {}
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all tokens (logout)
  /// Note: This does NOT clear remembered email - that's handled separately
  static Future<bool> clearTokens() async {
    try {
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.delete(_accessTokenKey);
      await SecureStorageHelper.delete(_refreshTokenKey);
      await SecureStorageHelper.delete(_userIdKey);
      await SecureStorageHelper.delete(_userDataKey);
      await _removeLegacySharedPreferenceKeys();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save onboarding completion status
  static Future<bool> setOnboardingCompleted(bool completed) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.writeBool(_onboardingCompletedKey, completed);
      return true;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        await SecureStorageHelper.writeBool(_onboardingCompletedKey, completed);
        return true;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      return await SecureStorageHelper.readBool(_onboardingCompletedKey) ??
          false;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        return await SecureStorageHelper.readBool(_onboardingCompletedKey) ??
            false;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Save remembered email for "Remember Me" functionality
  static Future<bool> saveRememberedEmail(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.write(_rememberedEmailKey, email);
      return true;
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        await SecureStorageHelper.write(_rememberedEmailKey, email);
        return true;
      } catch (retryError) {
        return false;
      }
    }
  }

  /// Get remembered email for "Remember Me" functionality
  static Future<String?> getRememberedEmail() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _ensureMigratedFromSharedPreferences();
      return SecureStorageHelper.read(_rememberedEmailKey);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await _ensureMigratedFromSharedPreferences();
        return SecureStorageHelper.read(_rememberedEmailKey);
      } catch (retryError) {
        return null;
      }
    }
  }

  /// Clear remembered email
  static Future<bool> clearRememberedEmail() async {
    try {
      await _ensureMigratedFromSharedPreferences();
      await SecureStorageHelper.delete(_rememberedEmailKey);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_legacyRememberedEmailKey);
      } catch (_) {}
      return true;
    } catch (e) {
      return false;
    }
  }
}
