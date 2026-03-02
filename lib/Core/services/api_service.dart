import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:imagifyai/Core/Constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Token refresh callback - should return new access token or null if refresh failed
  static Future<String?> Function()? _onTokenExpired;

  // Getter to check if callback is set (for debugging)
  static bool get hasTokenRefreshCallback => _onTokenExpired != null;

  // Set the token refresh callback
  static void setTokenRefreshCallback(Future<String?> Function() callback) {
    _onTokenExpired = callback;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
    bool retryOnTokenExpiry = true,
  }) async {
    return _executeWithTokenRefresh(
      () async {
        final uri = _buildUri(path, query);
        final response = await _client.get(
          uri,
          headers: _withDefaultHeaders(headers),
        );
        return response;
      },
      retryOnTokenExpiry: retryOnTokenExpiry,
      originalHeaders: headers,
      retryCallback: (newToken) async {
        final updatedHeaders = Map<String, String>.from(headers ?? {});
        updatedHeaders['Authorization'] = 'Bearer $newToken';
        final uri = _buildUri(path, query);
        return await _client.get(
          uri,
          headers: _withDefaultHeaders(updatedHeaders),
        );
      },
    );
  }

  // Get raw bytes (for image downloads)
  Future<Uint8List> getRaw(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _client.get(
      uri,
      headers: _withDefaultHeaders(headers),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }

    // If error, parse as JSON for error message
    final decoded = jsonDecode(response.body);
    final errorMessage =
        decoded['message']?.toString() ??
        decoded['msg']?.toString() ??
        decoded['error']?.toString();

    if (errorMessage == null || errorMessage.isEmpty) {
      throw ApiException(
        'Failed to download wallpaper',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
    bool retryOnTokenExpiry = true,
  }) async {
    return _executeWithTokenRefresh(
      () async {
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(headers, isJson: true);
        final response = await _client.post(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        return response;
      },
      retryOnTokenExpiry: retryOnTokenExpiry,
      originalHeaders: headers,
      retryCallback: (newToken) async {
        final updatedHeaders = Map<String, String>.from(headers ?? {});
        updatedHeaders['Authorization'] = 'Bearer $newToken';
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(updatedHeaders, isJson: true);
        return await _client.post(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
    bool retryOnTokenExpiry = true,
  }) async {
    return _executeWithTokenRefresh(
      () async {
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(headers, isJson: true);
        final response = await _client.put(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        return response;
      },
      retryOnTokenExpiry: retryOnTokenExpiry,
      originalHeaders: headers,
      retryCallback: (newToken) async {
        final updatedHeaders = Map<String, String>.from(headers ?? {});
        updatedHeaders['Authorization'] = 'Bearer $newToken';
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(updatedHeaders, isJson: true);
        return await _client.put(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
    bool retryOnTokenExpiry = true,
  }) async {
    return _executeWithTokenRefresh(
      () async {
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(headers, isJson: true);
        final request = http.Request('PATCH', uri);
        request.headers.addAll(mergedHeaders);
        if (body != null) {
          request.body = jsonEncode(body);
        }
        final streamedResponse = await _client.send(request);
        final response = await http.Response.fromStream(streamedResponse);
        return response;
      },
      retryOnTokenExpiry: retryOnTokenExpiry,
      originalHeaders: headers,
      retryCallback: (newToken) async {
        final updatedHeaders = Map<String, String>.from(headers ?? {});
        updatedHeaders['Authorization'] = 'Bearer $newToken';
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(updatedHeaders, isJson: true);
        final request = http.Request('PATCH', uri);
        request.headers.addAll(mergedHeaders);
        if (body != null) {
          request.body = jsonEncode(body);
        }
        final streamedResponse = await _client.send(request);
        final response = await http.Response.fromStream(streamedResponse);
        return response;
      },
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
    bool retryOnTokenExpiry = true,
  }) async {
    return _executeWithTokenRefresh(
      () async {
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(
          headers,
          isJson: body != null,
        );
        final response = await _client.delete(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        return response;
      },
      retryOnTokenExpiry: retryOnTokenExpiry,
      originalHeaders: headers,
      retryCallback: (newToken) async {
        final updatedHeaders = Map<String, String>.from(headers ?? {});
        updatedHeaders['Authorization'] = 'Bearer $newToken';
        final uri = _buildUri(path, query);
        final mergedHeaders = _withDefaultHeaders(
          updatedHeaders,
          isJson: body != null,
        );
        return await _client.delete(
          uri,
          headers: mergedHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      },
    );
  }

  Future<Map<String, dynamic>> postMultipart({
    required String path,
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'profile_image',
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri)..fields.addAll(fields);

    // For multipart requests, only add non-content-type headers
    // The Content-Type with boundary will be set automatically by http package
    final defaultHeaders = <String, String>{'accept': 'application/json'};
    if (headers != null && headers.isNotEmpty) {
      defaultHeaders.addAll(headers);
    }
    // Remove content-type if present, as it will be set automatically with boundary
    defaultHeaders.remove('content-type');
    request.headers.addAll(defaultHeaders);

    if (file != null) {
      try {
        final filename = file.path.split('/').last;
        final fileExtension = filename.split('.').last.toLowerCase();
        final contentType = _getContentType(fileExtension);
        final fileBytes = await file.readAsBytes();
        final mediaType = http.MediaType.parse(contentType);
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: filename,
            contentType: mediaType,
          ),
        );
      } catch (e) {
        rethrow;
      }
    }

    try {
      return _executeWithTokenRefresh(
        () async {
          final streamedResponse = await _client.send(request);
          return await http.Response.fromStream(streamedResponse);
        },
        retryOnTokenExpiry: true,
        originalHeaders: headers,
        retryCallback: (newToken) async {
          // Rebuild the request with updated headers for multipart
          final retryRequest = http.MultipartRequest('POST', uri)
            ..fields.addAll(fields);
          final retryHeaders = <String, String>{'accept': 'application/json'};
          if (headers != null && headers.isNotEmpty) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Authorization'] = 'Bearer $newToken';
          retryHeaders.remove('content-type');
          retryRequest.headers.addAll(retryHeaders);

          if (file != null) {
            final filename = file.path.split('/').last;
            final fileExtension = filename.split('.').last;
            final contentType = _getContentType(fileExtension);
            final fileBytes = await file.readAsBytes();
            final mediaType = http.MediaType.parse(contentType);
            retryRequest.files.add(
              http.MultipartFile.fromBytes(
                fileFieldName,
                fileBytes,
                filename: filename,
                contentType: mediaType,
              ),
            );
          }

          final streamedResponse = await _client.send(retryRequest);
          return await http.Response.fromStream(streamedResponse);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> putMultipart({
    required String path,
    File? file,
    String fileFieldName = 'profile_image',
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final request = http.MultipartRequest('PATCH', uri);

    // For multipart requests, only add non-content-type headers
    // The Content-Type with boundary will be set automatically by http package
    final defaultHeaders = <String, String>{'accept': 'application/json'};
    if (headers != null && headers.isNotEmpty) {
      defaultHeaders.addAll(headers);
    }
    // Remove content-type if present, as it will be set automatically with boundary
    defaultHeaders.remove('content-type');
    request.headers.addAll(defaultHeaders);

    if (file != null) {
      try {
        final filename = file.path.split('/').last;
        final fileExtension = filename.split('.').last.toLowerCase();
        final contentType = _getContentType(fileExtension);
        final fileBytes = await file.readAsBytes();
        final mediaType = http.MediaType.parse(contentType);
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: filename,
            contentType: mediaType,
          ),
        );
      } catch (e) {
        rethrow;
      }
    }

    try {
      return _executeWithTokenRefresh(
        () async {
          final streamedResponse = await _client.send(request);
          return await http.Response.fromStream(streamedResponse);
        },
        retryOnTokenExpiry: true,
        originalHeaders: headers,
        retryCallback: (newToken) async {
          // Rebuild the request with updated headers for multipart
          final retryRequest = http.MultipartRequest('PATCH', uri);
          final retryHeaders = <String, String>{'accept': 'application/json'};
          if (headers != null && headers.isNotEmpty) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Authorization'] = 'Bearer $newToken';
          retryHeaders.remove('content-type');
          retryRequest.headers.addAll(retryHeaders);

          if (file != null) {
            final filename = file.path.split('/').last;
            final fileExtension = filename.split('.').last.toLowerCase();
            final contentType = _getContentType(fileExtension);
            final fileBytes = await file.readAsBytes();
            final mediaType = http.MediaType.parse(contentType);
            retryRequest.files.add(
              http.MultipartFile.fromBytes(
                fileFieldName,
                fileBytes,
                filename: filename,
                contentType: mediaType,
              ),
            );
          }

          final streamedResponse = await _client.send(retryRequest);
          return await http.Response.fromStream(streamedResponse);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Execute a request with automatic token refresh on 401 errors
  Future<Map<String, dynamic>> _executeWithTokenRefresh(
    Future<http.Response> Function() requestFn, {
    required bool retryOnTokenExpiry,
    Map<String, String>? originalHeaders,
    Future<http.Response> Function(String newToken)? retryCallback,
  }) async {
    try {
      final response = await requestFn();

      // Check if token expired
      if (retryOnTokenExpiry &&
          response.statusCode == 401 &&
          _isTokenExpiredError(response)) {
        if (_onTokenExpired != null) {
          final newToken = await _onTokenExpired!();
          if (newToken != null && newToken.isNotEmpty && retryCallback != null) {
            final retryResponse = await retryCallback(newToken);
            return _handleResponse(retryResponse);
          }
        }
      }

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    }
  }

  /// Check if the error response indicates token expiration
  bool _isTokenExpiredError(http.Response response) {
    try {
      if (response.body.isEmpty) return false;
      final decoded = jsonDecode(response.body);
      final errorMessage =
          (decoded['msg'] ?? decoded['message'] ?? decoded['error'] ?? '')
              .toString()
              .toLowerCase();
      return errorMessage.contains('token has expired') ||
          errorMessage.contains('token expired') ||
          errorMessage.contains('expired token') ||
          errorMessage.contains('invalid token');
    } catch (_) {
      return false;
    }
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConstants.baseUrl}$path',
    ).replace(queryParameters: query);
  }

  Map<String, String> _withDefaultHeaders(
    Map<String, String>? headers, {
    bool isJson = false,
  }) {
    final defaultHeaders = <String, String>{'accept': 'application/json'};
    if (isJson) {
      defaultHeaders['content-type'] = 'application/json';
    }
    if (headers != null && headers.isNotEmpty) {
      defaultHeaders.addAll(headers);
    }
    return defaultHeaders;
  }

  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default to jpeg
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = _decodeResponseBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    // Extract error message - check multiple possible fields
    String? errorMessage;

    // Check 'detail' field first (can be string or array)
    if (decoded.containsKey('detail')) {
      final detail = decoded['detail'];
      if (detail is List && detail.isNotEmpty) {
        // Handle array format: [{"loc": ["field"], "msg": "Error message", "type": "value_error"}]
        final firstError = detail[0];
        if (firstError is Map) {
          errorMessage =
              firstError['msg']?.toString() ??
              firstError['message']?.toString();
        }
        if (errorMessage == null || errorMessage.isEmpty) {
          errorMessage = detail.toString();
        }
      } else {
        // Handle string format: "Not Found"
        errorMessage = detail?.toString();
      }
    }

    // Check 'msg' field (used by some APIs)
    if ((errorMessage == null || errorMessage.isEmpty) &&
        decoded.containsKey('msg')) {
      errorMessage = decoded['msg']?.toString();
    }

    // Check 'message' field
    if ((errorMessage == null || errorMessage.isEmpty) &&
        decoded.containsKey('message')) {
      errorMessage = decoded['message']?.toString();
    }

    // Check 'error' field
    if ((errorMessage == null || errorMessage.isEmpty) &&
        decoded.containsKey('error')) {
      errorMessage = decoded['error']?.toString();
    }

    if (errorMessage == null || errorMessage.isEmpty) {
      throw ApiException(
        'API request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  Map<String, dynamic> _decodeResponseBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    final trimmed = response.body
        .replaceFirst(RegExp(r'^\uFEFF'), '')
        .trimLeft()
        .toLowerCase();
    final looksLikeHtml =
        trimmed.startsWith('<!') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('<!doctype') ||
        (trimmed.length > 10 && trimmed.substring(0, 10).contains('<'));
    if (looksLikeHtml) {
      throw ApiException(
        'The server returned a web page instead of API data. The API URL may be wrong or the server may be misconfigured. Please try again later.',
        statusCode: response.statusCode,
      );
    }

    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List) {
        return {'data': decoded};
      }
      return {'data': decoded};
    } catch (e) {
      final body = response.body.toLowerCase();
      if (body.contains('<!doctype') || body.contains('<html')) {
        throw ApiException(
          'The server returned a web page instead of API data. The API URL may be wrong or the server may be misconfigured. Please try again later.',
          statusCode: response.statusCode,
        );
      }
      if (response.body.isNotEmpty &&
          (response.body.contains('message') ||
              response.body.contains('error'))) {
        return {'message': response.body, 'status': false};
      }
      throw ApiException(
        'Unable to parse server response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
}
