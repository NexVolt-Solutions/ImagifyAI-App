class UpdatePasswordResponse {
  UpdatePasswordResponse({
    this.message,
    this.status,
  });

  final String? message;
  final bool? status;

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      message: json['message']?.toString(),
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

