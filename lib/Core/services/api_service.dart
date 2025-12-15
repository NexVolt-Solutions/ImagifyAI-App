import 'dart:convert';
import 'dart:io';

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

    final request = http.MultipartRequest('POST', uri)
      ..fields.addAll(fields)
      ..headers.addAll(_withDefaultHeaders(headers));

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> putMultipart({
    required String path,
    File? file,
    String fileFieldName = 'profile_image',
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);

    final request = http.MultipartRequest('PUT', uri)
      ..headers.addAll(_withDefaultHeaders(headers));

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileFieldName, file.path));
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
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

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = _decodeResponseBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      decoded['message']?.toString() ?? 'Something went wrong',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeResponseBody(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    } catch (_) {
      return {'message': 'Unable to parse response'};
    }
  }
}

