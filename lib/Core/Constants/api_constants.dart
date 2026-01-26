class ApiConstants {
  ApiConstants._();
  // Note: If 404 errors occur, the API might require /api/v1 prefix
  static const String baseUrl = 'https://imagifyai.io/api/v1';
  // Authentication endpoints
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify';
  static const String resendCode = '/auth/resend-code';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyForgotOtp = '/auth/verify-forgot-otp';
  static const String setNewPassword = '/auth/set-new-password';
  static const String resetPassword = '/auth/reset-password';
  static const String googleSignIn = '/auth/google';
  static const String signOut = '/auth/sign-out';
  // Use helper methods in repository to construct paths with user_id
  static const String getCurrentUser = '/users'; // Will be /users/{user_id}
  static const String updateUser = '/users'; // Will be /users/{user_id}
  static const String updateUserProfile = '/users'; // Will be /users/{user_id}/profile
  static const String updatePassword = '/users'; // Will be /users/{user_id}/password
  static const String deleteAccount = '/users'; // Will be /users/{user_id}

  // Wallpaper endpoints
  static const String suggestPrompt = '/wallpapers/suggest';
  static const String wallpapers = '/wallpapers/';
  static const String groupedWallpapers = '/wallpapers/grouped';
  static const String wallpapersStyles = '/wallpapers/styles';
  static const String recreateWallpaper = '/wallpapers'; // Will be /wallpapers/{wallpaper_id}/recreate
  static const String downloadWallpaper = '/wallpapers'; // Will be /wallpapers/{wallpaper_id}/download
  static const String deleteWallpaper = '/wallpapers'; // Will be /wallpapers/{wallpaper_id}
  static const String googleWebClientId = '247136119306-p8qvdr6se04jf40t1ha3hqlu7jl36blg.apps.googleusercontent.com';
}

