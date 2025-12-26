class RefreshResponse {
  RefreshResponse({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.message,
    this.status,
    this.data,
    this.userId,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final String? message;
  final bool? status;
  final dynamic data;
  final String? userId;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      accessToken: json['access_token']?.toString(),
      refreshToken: json['refresh_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      message: json['message']?.toString(),
      status: json['status'] is bool ? json['status'] as bool : _parseStatus(json['status']),
      data: json['data'],
      userId: json['user_id']?.toString(),
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

