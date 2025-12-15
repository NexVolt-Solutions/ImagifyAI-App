class RegisterResponse {
  RegisterResponse({
    this.message,
    this.data,
    this.status,
  });

  final String? message;
  final dynamic data;
  final bool? status;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message']?.toString(),
      data: json['data'],
      status: json['status'] is bool ? json['status'] as bool : _parseStatus(json['status']),
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

