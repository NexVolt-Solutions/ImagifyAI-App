import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:http/http.dart' as http;

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

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _client.get(uri, headers: _withDefaultHeaders(headers));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final mergedHeaders = _withDefaultHeaders(headers, isJson: true);
    final response = await _client.post(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final mergedHeaders = _withDefaultHeaders(headers, isJson: true);
    final response = await _client.put(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final mergedHeaders = _withDefaultHeaders(headers, isJson: body != null);
    final response = await _client.delete(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
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

    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields);

    // For multipart requests, only add non-content-type headers
    // The Content-Type with boundary will be set automatically by http package
    final defaultHeaders = <String, String>{
      'accept': 'application/json',
    };
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
        final fileExtension = filename.split('.').last;
        final contentType = _getContentType(fileExtension);
        
        if (kDebugMode) {
          print('Filename: $filename');
          print('Content-Type: $contentType');
        }
        
        // Use fromPath - it's more efficient and http package auto-detects content-type
        // The content-type will be automatically set based on file extension
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          filename: filename,
        ));
        
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
      print('Request fields count: ${request.fields.length}');
      print('Request files count: ${request.files.length}');
      print('Request fields: ${request.fields}');
      if (request.files.isNotEmpty) {
        for (var file in request.files) {
          print('File in request: field=${file.field}, filename=${file.filename}, length=${file.length}');
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
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (kDebugMode) {
        print('=== HTTP RESPONSE ===');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Response headers: ${response.headers}');
      }
      
      return _handleResponse(response);
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
  }) async {
    final uri = _buildUri(path);

    if (kDebugMode) {
      print('=== API SERVICE: PUT MULTIPART ===');
      print('URL: $uri');
      print('File: ${file?.path}');
      print('File field name: $fileFieldName');
    }

    final request = http.MultipartRequest('PUT', uri);

    // For multipart requests, only add non-content-type headers
    // The Content-Type with boundary will be set automatically by http package
    final defaultHeaders = <String, String>{
      'accept': 'application/json',
    };
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
        final fileExtension = filename.split('.').last;
        final contentType = _getContentType(fileExtension);
        
        if (kDebugMode) {
          print('Filename: $filename');
          print('Content-Type: $contentType');
        }
        
        // Use fromPath - it's more efficient and http package auto-detects content-type
        // The content-type will be automatically set based on file extension
        request.files.add(await http.MultipartFile.fromPath(
          fileFieldName,
          file.path,
          filename: filename,
        ));
        
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
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
      
      if (kDebugMode) {
        print('=== HTTP RESPONSE ===');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Response headers: ${response.headers}');
      }
      
    return _handleResponse(response);
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

  Uri _buildUri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: query);
  }

  Map<String, String> _withDefaultHeaders(Map<String, String>? headers,
      {bool isJson = false}) {
    final defaultHeaders = <String, String>{
      'accept': 'application/json',
    };
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

    // Check for error message in various possible fields
    final errorMessage = decoded['message']?.toString() ?? 
                        decoded['msg']?.toString() ?? 
                        decoded['error']?.toString() ?? 
                        decoded['errors']?.toString() ??
                        'Something went wrong';
    
    if (kDebugMode) {
      print('=== THROWING API EXCEPTION ===');
      print('Status code: ${response.statusCode}');
      print('Decoded response keys: ${decoded.keys.toList()}');
      print('Error message found: $errorMessage');
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
    );
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

