import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      print('✅ ApiService: Token refresh callback has been set');
      print('   Callback is null: ${_onTokenExpired == null}');
    }
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

    if (kDebugMode) {
      print('=== API SERVICE: POST MULTIPART ===');
      print('URL: $uri');
      print('Fields: $fields');
      print('File: ${file?.path}');
      print('File field name: $fileFieldName');
    }

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
      if (kDebugMode) {
        print('Adding file to request: ${file.path}');
      }
      try {
        // Extract filename from path
        final filename = file.path.split('/').last;
        final fileExtension = filename.split('.').last.toLowerCase();
        final contentType = _getContentType(fileExtension);

        if (kDebugMode) {
          print('Filename: $filename');
          print('Content-Type: $contentType');
        }

        // Read file bytes and create MultipartFile with explicit content-type
        // Some servers require explicit content-type in the multipart file
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

        if (kDebugMode) {
          print('File added successfully');
          print('File bytes length: ${fileBytes.length}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('ERROR adding file: $e');
        }
        rethrow;
      }
    }

    if (kDebugMode) {
      print('Request headers: ${request.headers}');
      print('Request fields count: ${request.fields.length}');
      print('Request files count: ${request.files.length}');
      print('Request fields: ${request.fields}');
      if (request.files.isNotEmpty) {
        for (var file in request.files) {
          print(
            'File in request: field=${file.field}, filename=${file.filename}, length=${file.length}, contentType=${file.contentType}',
          );
        }
      }
      if (file != null) {
        final fileSize = await file.length();
        print('Actual file size: $fileSize bytes');
        print('File exists: ${await file.exists()}');
      }
      print('Full request URL: ${request.url}');
      print('Request method: ${request.method}');
    }

    try {
      if (kDebugMode) {
        print('Sending multipart request...');
      }
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR IN POST MULTIPART ===');
        print('Exception type: ${e.runtimeType}');
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
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

    if (kDebugMode) {
      print('=== API SERVICE: PATCH MULTIPART ===');
      print('URL: $uri');
      print('Query parameters: $query');
      print('File: ${file?.path}');
      print('File field name: $fileFieldName');
    }

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
      if (kDebugMode) {
        print('Adding file to request: ${file.path}');
      }
      try {
        // Extract filename from path
        final filename = file.path.split('/').last;
        final fileExtension = filename.split('.').last.toLowerCase();
        final contentType = _getContentType(fileExtension);

        if (kDebugMode) {
          print('Filename: $filename');
          print('Content-Type: $contentType');
        }

        // Read file bytes and create MultipartFile with explicit content-type
        // Some servers require explicit content-type in the multipart file
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

        if (kDebugMode) {
          print('File added successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('ERROR adding file: $e');
        }
        rethrow;
      }
    }

    if (kDebugMode) {
      print('Request headers: ${request.headers}');
    }

    try {
      if (kDebugMode) {
        print('Sending multipart request...');
      }

      return _executeWithTokenRefresh(
        () async {
          final streamedResponse = await _client.send(request);
          final response = await http.Response.fromStream(streamedResponse);

          if (kDebugMode) {
            print('=== HTTP RESPONSE ===');
            print('Status code: ${response.statusCode}');
            print('Response body: ${response.body}');
            print('Response headers: ${response.headers}');
          }

          return response;
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

            if (kDebugMode) {
              print('=== RETRY: Adding file ===');
              print('Filename: $filename');
              print('File extension: $fileExtension');
              print('Content-Type: $contentType');
              print('File bytes length: ${fileBytes.length}');
            }

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
          final retryResponse = await http.Response.fromStream(
            streamedResponse,
          );

          if (kDebugMode) {
            print('=== RETRY HTTP RESPONSE ===');
            print('Status code: ${retryResponse.statusCode}');
            print('Response body: ${retryResponse.body}');
          }

          return retryResponse;
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR IN PUT MULTIPART ===');
        print('Exception type: ${e.runtimeType}');
        print('Exception: $e');
        print('Stack trace: $stackTrace');
      }
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
        if (kDebugMode) {
          print('🔄 Token expired (401), attempting to refresh...');
        }

        // Try to refresh token
        if (kDebugMode) {
          print('   Checking token refresh callback...');
          print('   Callback is null: ${_onTokenExpired == null}');
        }
        if (_onTokenExpired != null) {
          final newToken = await _onTokenExpired!();

          if (newToken != null && newToken.isNotEmpty) {
            if (kDebugMode) {
              print('✅ Token refreshed, retrying request...');
            }

            // Retry the request with new token
            if (retryCallback != null) {
              final retryResponse = await retryCallback(newToken);
              return _handleResponse(retryResponse);
            } else {
              if (kDebugMode) {
                print('⚠️  No retry callback provided, cannot retry request');
              }
            }
          } else {
            if (kDebugMode) {
              print('❌ Token refresh failed or returned null');
            }
          }
        } else {
          if (kDebugMode) {
            print('⚠️  No token refresh callback set');
            print('   Attempting to set callback again...');
            // Try to set it again - might have been reset by hot reload
            // This is a fallback, but the callback should be set in main() and initState()
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
    if (kDebugMode) {
      print('=== HANDLING RESPONSE ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    final decoded = _decodeResponseBody(response);

    if (kDebugMode) {
      print('Decoded response: $decoded');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (kDebugMode) {
        print('Status code is success (200-299), returning decoded response');
      }
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

    // If no error message found, throw with status code only
    if (errorMessage == null || errorMessage.isEmpty) {
      if (kDebugMode) {
        print('⚠️  No error message found in response');
        print('Response keys: ${decoded.keys.toList()}');
        print('Full response: $decoded');
      }
      throw ApiException(
        'API request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (kDebugMode) {
      print('=== THROWING API EXCEPTION ===');
      print('Status code: ${response.statusCode}');
      print('Decoded response keys: ${decoded.keys.toList()}');
      print('Error message found: $errorMessage');
    }

    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  Map<String, dynamic> _decodeResponseBody(http.Response response) {
    if (kDebugMode) {
      print('=== DECODING RESPONSE BODY ===');
      print('Body length: ${response.body.length}');
      print('Body empty: ${response.body.isEmpty}');
    }

    if (response.body.isEmpty) {
      if (kDebugMode) {
        print('Response body is empty, returning empty map');
      }
      return {};
    }

    try {
      if (kDebugMode) {
        print('Attempting to JSON decode response body...');
      }
      final dynamic decoded = jsonDecode(response.body);

      if (kDebugMode) {
        print('JSON decoded successfully');
        print('Decoded type: ${decoded.runtimeType}');
      }

      if (decoded is Map<String, dynamic>) {
        if (kDebugMode) {
          print('Decoded is Map, returning as-is');
        }
        return decoded;
      }
      if (decoded is List) {
        if (kDebugMode) {
          print('Decoded is List, wrapping in data field');
        }
        return {'data': decoded};
      }
      if (kDebugMode) {
        print('Decoded is other type, wrapping in data field');
      }
      return {'data': decoded};
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== ERROR DECODING JSON ===');
        print('Exception: $e');
        print('Stack trace: $stackTrace');
        print('Response body: ${response.body}');
      }

      // If JSON parsing fails, try to extract error message from response
      final body = response.body;
      if (body.isNotEmpty) {
        // Try to find error message in plain text response
        if (body.contains('message') || body.contains('error')) {
          if (kDebugMode) {
            print('Found message/error in plain text, returning as message');
          }
          return {'message': body, 'status': false};
        }
      }

      if (kDebugMode) {
        print('Throwing ApiException for JSON parse error');
      }
      throw ApiException(
        'Unable to parse server response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
}
