import 'dart:convert';

class JwtDecoder {
  /// Decodes a JWT token and returns the payload as a Map
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed for base64 decoding
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final payloadMap = json.decode(decodedString) as Map<String, dynamic>;
      
      return payloadMap;
    } catch (e) {
      return null;
    }
  }

  /// Extracts user_id from JWT token
  /// Checks for: user_id, userId, sub (which might be user_id or email)
  static String? getUserId(String token) {
    final payload = decode(token);
    if (payload == null) return null;
    
    // Try different possible field names for user_id
    return payload['user_id']?.toString() ?? 
           payload['userId']?.toString() ?? 
           payload['id']?.toString() ??
           payload['sub']?.toString(); // sub might be user_id or email
  }

  /// Extracts email from JWT token
  static String? getEmail(String token) {
    final payload = decode(token);
    if (payload == null) return null;
    
    return payload['email']?.toString() ?? 
           payload['sub']?.toString(); // sub might be email
  }
}

