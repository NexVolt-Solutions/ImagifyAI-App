class ForgotPasswordResponse {
  ForgotPasswordResponse({
    this.message,
    this.status,
    this.data,
  });

  final String? message;
  final bool? status;
  final dynamic data;

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message']?.toString(),
      status: json['status'] is bool ? json['status'] as bool : _parseStatus(json['status']),
      data: json['data'],
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

