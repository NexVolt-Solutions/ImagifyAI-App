class LoginResponse {
  LoginResponse({
    this.message,
    this.status,
    this.data,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  final String? message;
  final bool? status;
  final dynamic data;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message']?.toString(),
      status: json['status'] is bool ? json['status'] as bool : _parseStatus(json['status']),
      data: json['data'],
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      tokenType: json['token_type']?.toString(),
    );
  }

  static bool? _parseStatus(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == 'success') return true;
      if (lower == 'false' || lower == 'failed') return false;
    }
    return null;
  }
}

