import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _rememberedEmailKey = 'remembered_email';

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
  /// Note: This does NOT clear remembered email - that's handled separately
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

  /// Save onboarding completion status
  static Future<bool> setOnboardingCompleted(bool completed) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setBool(_onboardingCompletedKey, completed);
      
      if (kDebugMode) {
        print('=== ONBOARDING STATUS SAVED ===');
        print('Onboarding completed: $completed');
        print('Saved: $saved');
      }
      
      return saved;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving onboarding status: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return await prefs.setBool(_onboardingCompletedKey, completed);
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return false;
    }
  }

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_onboardingCompletedKey) ?? false;
      
      if (kDebugMode) {
        print('=== CHECKING ONBOARDING STATUS ===');
        print('Onboarding completed: $completed');
      }
      
      return completed;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking onboarding status: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return prefs.getBool(_onboardingCompletedKey) ?? false;
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return false;
    }
  }

  /// Save remembered email for "Remember Me" functionality
  static Future<bool> saveRememberedEmail(String email) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(_rememberedEmailKey, email);
      
      if (kDebugMode) {
        print('=== REMEMBERED EMAIL SAVED ===');
        print('Email saved: $email');
        print('Saved: $saved');
      }
      
      return saved;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving remembered email: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return await prefs.setString(_rememberedEmailKey, email);
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return false;
    }
  }

  /// Get remembered email for "Remember Me" functionality
  static Future<String?> getRememberedEmail() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_rememberedEmailKey);
      
      if (kDebugMode) {
        print('=== GETTING REMEMBERED EMAIL ===');
        print('Email found: ${email != null && email.isNotEmpty}');
        if (email != null) {
          print('Email: $email');
        }
      }
      
      return email;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting remembered email: $e');
        // Retry once
        try {
          await Future.delayed(const Duration(milliseconds: 500));
          final prefs = await SharedPreferences.getInstance();
          return prefs.getString(_rememberedEmailKey);
        } catch (retryError) {
          if (kDebugMode) {
            print('Retry also failed: $retryError');
          }
        }
      }
      return null;
    }
  }

  /// Clear remembered email
  static Future<bool> clearRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final removed = await prefs.remove(_rememberedEmailKey);
      
      if (kDebugMode) {
        print('=== REMEMBERED EMAIL CLEARED ===');
        print('Email removed: $removed');
      }
      
      return removed;
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing remembered email: $e');
      }
      return false;
    }
  }
}

