import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  /// Save access token to SharedPreferences
  static Future<bool> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_accessTokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving access token: $e');
      }
      return false;
    }
  }

  /// Save refresh token to SharedPreferences
  static Future<bool> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving refresh token: $e');
      }
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
      
      if (kDebugMode) {
        print('=== TOKENS SAVED ===');
        print('Access token saved: $accessSaved');
        print('Refresh token saved: $refreshSaved');
      }
      
      return accessSaved && refreshSaved;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving tokens: $e');
        // Retry once after a delay
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          final accessSaved = await prefs.setString(_accessTokenKey, accessToken);
          final refreshSaved = await prefs.setString(_refreshTokenKey, refreshToken);
          if (kDebugMode) {
            print('Retry successful - Access: $accessSaved, Refresh: $refreshSaved');
          }
          return accessSaved && refreshSaved;
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return false;
    }
  }

  /// Get access token from SharedPreferences
  static Future<String?> getAccessToken() async {
    try {
      // Add a small delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_accessTokenKey);
      
      if (kDebugMode) {
        print('=== GETTING ACCESS TOKEN ===');
        print('Token found: ${token != null && token.isNotEmpty}');
        if (token != null) {
          print('Token length: ${token.length}');
        }
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting access token: $e');
        // Retry once after a delay
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_accessTokenKey);
          if (kDebugMode) {
            print('Retry successful: ${token != null && token.isNotEmpty}');
          }
          return token;
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return null;
    }
  }

  /// Get refresh token from SharedPreferences
  static Future<String?> getRefreshToken() async {
    try {
      // Add a small delay to ensure platform channel is ready
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_refreshTokenKey);
      
      if (kDebugMode) {
        print('=== GETTING REFRESH TOKEN ===');
        print('Token found: ${token != null && token.isNotEmpty}');
      }
      
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting refresh token: $e');
        // Retry once after a delay
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_refreshTokenKey);
          if (kDebugMode) {
            print('Retry successful: ${token != null && token.isNotEmpty}');
          }
          return token;
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return null;
    }
  }

  /// Check if user is logged in (has tokens)
  static Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final loggedIn = accessToken != null && 
                       accessToken.isNotEmpty && 
                       refreshToken != null && 
                       refreshToken.isNotEmpty;
      
      if (kDebugMode) {
        print('=== CHECKING LOGIN STATUS ===');
        print('Has access token: ${accessToken != null && accessToken.isNotEmpty}');
        print('Has refresh token: ${refreshToken != null && refreshToken.isNotEmpty}');
        print('Is logged in: $loggedIn');
      }
      
      return loggedIn;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      return false;
    }
  }

  /// Save user_id to SharedPreferences
  static Future<bool> saveUserId(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_userIdKey, userId);
      
      if (kDebugMode) {
        print('=== USER ID SAVED ===');
        print('User ID: $userId');
        print('Saved: $saved');
      }
      
      return saved;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user_id: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return await prefs.setString(_userIdKey, userId);
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return false;
    }
  }

  /// Get user_id from SharedPreferences
  static Future<String?> getUserId() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (kDebugMode) {
        print('=== GETTING USER ID ===');
        print('User ID found: ${userId != null && userId.isNotEmpty}');
        if (userId != null) {
          print('User ID: $userId');
        }
      }
      
      return userId;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user_id: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return prefs.getString(_userIdKey);
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return null;
    }
  }

  /// Clear all tokens (logout)
  static Future<bool> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessRemoved = await prefs.remove(_accessTokenKey);
      final refreshRemoved = await prefs.remove(_refreshTokenKey);
      final userIdRemoved = await prefs.remove(_userIdKey);
      
      if (kDebugMode) {
        print('=== TOKENS CLEARED ===');
        print('Access token removed: $accessRemoved');
        print('Refresh token removed: $refreshRemoved');
        print('User ID removed: $userIdRemoved');
      }
      
      return accessRemoved && refreshRemoved && userIdRemoved;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing tokens: $e');
      }
      return false;
    }
  }
}

