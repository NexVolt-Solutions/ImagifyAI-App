import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/models/wallpaper/suggest_response.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

class WallpaperRepository {
  WallpaperRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<SuggestResponse> suggestPrompt({
    required String prompt,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    final json = await _apiService.post(
      ApiConstants.suggestPrompt,
      body: {'prompt': prompt},
      headers: headers,
    );
    return SuggestResponse.fromJson(json);
  }

  Future<List<Wallpaper>> fetchWallpapers({
    required String accessToken,
    int page = 1,
    int limit = 10,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== FETCH WALLPAPERS API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: GET ${ApiConstants.wallpapers}');
      print('Page: $page, Limit: $limit');
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Build query parameters for pagination
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final json = await _apiService.get(
      ApiConstants.wallpapers,
      headers: headers,
      query: queryParams,
    );

    if (!json.containsKey('wallpapers')) {
      if (kDebugMode) {
        print('❌ Invalid response: wallpapers field missing');
        print('Response keys: ${json.keys.toList()}');
      }
      throw ApiException(
        'Invalid response: wallpapers field missing',
        statusCode: 500,
      );
    }

    final list = json['wallpapers'] as List;
    final wallpapers = list
        .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
        .toList();

    if (kDebugMode) {
      print('✅ Wallpapers fetched successfully');
      print('Count: ${wallpapers.length}');
      print('═══════════════════════════════════════════════════════════');
      print('=== FETCH WALLPAPERS API: SUCCESS ===');
      print('═══════════════════════════════════════════════════════════');
    }

    return wallpapers;
  }

  Future<Wallpaper> createWallpaper({
    required String prompt,
    required String size,
    required String style,
    String? title,
    String? aiModel,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== CREATE WALLPAPER API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: POST ${ApiConstants.wallpapers}');
      print('--- Request Data ---');
      print('Prompt: $prompt');
      print('Size: $size');
      print('Style: $style');
      if (title != null && title.isNotEmpty) {
        print('Title: $title');
      }
      if (aiModel != null && aiModel.isNotEmpty) {
        print('AI Model: $aiModel');
      }
      print('Access token present: ${accessToken.isNotEmpty}');
      print('Access token length: ${accessToken.length}');
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    final body = <String, dynamic>{
      'prompt': prompt,
      'size': size,
      'style': style,
    };

    // Optional fields - only include if provided
    if (title != null && title.isNotEmpty) {
      body['title'] = title;
    }
    if (aiModel != null && aiModel.isNotEmpty) {
      body['ai_model'] = aiModel;
    }

    if (kDebugMode) {
      print('--- Request Body ---');
      print('Body: $body');
      print('--- Sending Request ---');
    }

    try {
      final json = await _apiService.post(
        ApiConstants.wallpapers,
        body: body,
        headers: headers,
      );

      if (kDebugMode) {
        print('✅ Response received successfully');
        print('--- Response Data ---');
        print('Response type: ${json.runtimeType}');
        print('Response keys: ${json.keys.toList()}');
        if (json.containsKey('id')) {
          print('Wallpaper ID: ${json['id']}');
        }
        if (json.containsKey('prompt')) {
          print('Prompt: ${json['prompt']}');
        }
        if (json.containsKey('size')) {
          print('Size: ${json['size']}');
        }
        if (json.containsKey('style')) {
          print('Style: ${json['style']}');
        }
        if (json.containsKey('status')) {
          print('Status: ${json['status']}');
        }
        if (json.containsKey('image_url')) {
          print('Image URL: ${json['image_url']}');
        }
        if (json.containsKey('created_at')) {
          print('Created At: ${json['created_at']}');
        }
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER API: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }

      return Wallpaper.fromJson(json);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error in createWallpaper API call');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is ApiException) {
          print('Status code: ${e.statusCode}');
          print('Message: ${e.message}');
        }
        print('--- Stack Trace ---');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
        print('=== CREATE WALLPAPER API: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  Future<Wallpaper?> getWallpaperById({
    required String wallpaperId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== GET WALLPAPER BY ID API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: GET ${ApiConstants.wallpapers}');
      print('Wallpaper ID: $wallpaperId');
      print('Note: Using list endpoint and filtering by ID');
    }

    try {
      // Backend doesn't support GET /wallpapers/{id}
      // So we fetch the list and find the wallpaper by ID
      final json = await _apiService.get(
        ApiConstants.wallpapers,
        headers: headers,
      );

      if (!json.containsKey('wallpapers')) {
        if (kDebugMode) {
          print('❌ Invalid response: wallpapers field missing');
        }
        return null;
      }

      final list = json['wallpapers'] as List;
      Map<String, dynamic>? wallpaperMap;

      try {
        wallpaperMap =
            list.firstWhere(
                  (e) =>
                      (e as Map<String, dynamic>)['id']?.toString() ==
                      wallpaperId,
                )
                as Map<String, dynamic>;
      } catch (e) {
        // Wallpaper not found in list
        wallpaperMap = null;
      }

      if (wallpaperMap == null) {
        if (kDebugMode) {
          print('❌ Wallpaper not found with ID: $wallpaperId');
        }
        return null;
      }

      final wallpaper = Wallpaper.fromJson(wallpaperMap);

      if (kDebugMode) {
        print('✅ Wallpaper found');
        print('Image URL: ${wallpaper.imageUrl}');
        print('═══════════════════════════════════════════════════════════');
        print('=== GET WALLPAPER BY ID API: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }

      return wallpaper;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error in getWallpaperById API call');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is ApiException) {
          print('Status code: ${e.statusCode}');
          print('Message: ${e.message}');
        }
        print('--- Stack Trace ---');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
        print('=== GET WALLPAPER BY ID API: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  Future<Wallpaper> recreateWallpaper({
    required String wallpaperId,
    required String accessToken,
    String? prompt,
    String? size,
    String? style,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== RECREATE WALLPAPER API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Wallpaper ID: $wallpaperId');
      if (prompt != null) print('Updated Prompt: $prompt');
      if (size != null) print('Size: $size');
      if (style != null) print('Style: $style');
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Build request body with optional parameters
    final body = <String, dynamic>{};
    if (prompt != null && prompt.isNotEmpty) {
      body['prompt'] = prompt.trim(); // Ensure trimmed prompt
    }
    if (size != null && size.isNotEmpty) {
      body['size'] = size;
    }
    if (style != null && style.isNotEmpty) {
      body['style'] = style;
    }

    if (kDebugMode) {
      print('--- Request Body ---');
      print('Body map: $body');
      print('Body is empty: ${body.isEmpty}');
      if (body.isNotEmpty) {
        print('Body will be sent: ${jsonEncode(body)}');
      } else {
        print('⚠️ WARNING: Body is empty, no parameters will be sent!');
      }
    }

    final path = '${ApiConstants.recreateWallpaper}/$wallpaperId/recreate';
    final json = await _apiService.post(
      path,
      headers: headers,
      body: body.isNotEmpty ? body : null,
    );

    if (kDebugMode) {
      print('✅ Wallpaper recreated successfully');
      print('═══════════════════════════════════════════════════════════');
      print('=== RECREATE WALLPAPER API: SUCCESS ===');
      print('═══════════════════════════════════════════════════════════');

      // Check if API used the prompt we sent
      final returnedPrompt = json['prompt']?.toString() ?? '';
      final sentPrompt = prompt?.trim() ?? '';
      if (sentPrompt.isNotEmpty && returnedPrompt != sentPrompt) {
        print('⚠️ BACKEND ISSUE DETECTED:');
        print('   Prompt we sent: "$sentPrompt"');
        print('   Prompt API returned: "$returnedPrompt"');
        print('   The backend is NOT using the prompt from the request body!');
        print('   The generated image will be based on the old prompt.');
      }
    }

    return Wallpaper.fromJson(json);
  }

  Future<Wallpaper> downloadWallpaper({
    required String wallpaperId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    final path = '${ApiConstants.downloadWallpaper}/$wallpaperId/download';

    // Download API now returns JSON with wallpaper data including image_url
    final json = await _apiService.get(path, headers: headers);
    return Wallpaper.fromJson(json);
  }

  Future<void> deleteWallpaper({
    required String wallpaperId,
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // DELETE /wallpapers/{wallpaper_id}
    await _apiService.delete(
      '${ApiConstants.deleteWallpaper}/$wallpaperId',
      headers: headers,
    );
  }

  Future<Map<String, List<Wallpaper>>> fetchGroupedWallpapers({
    required String accessToken,
    int page = 1,
    int limit = 4, // Reduced to 4 per category for faster initial load
  }) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== FETCH GROUPED WALLPAPERS API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: GET ${ApiConstants.groupedWallpapers}');
      print(
        'Note: This should return general/public wallpapers, not user-specific',
      );
      print('Page: $page, Limit: $limit');
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Add query parameter to exclude user-specific wallpapers
    // The backend should return general wallpapers for all users
    final queryParams = <String, String>{
      'public': 'true', // Request public/general wallpapers only
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (kDebugMode) {
      print('Query parameters: $queryParams');
      print('Requesting public/general wallpapers (excluding user-specific)');
    }

    try {
      final json = await _apiService.get(
        ApiConstants.groupedWallpapers,
        headers: headers,
        query: queryParams,
      );

      if (kDebugMode) {
        print('✅ Response received successfully');
        print('Response type: ${json.runtimeType}');
        print('Response keys: ${json.keys.toList()}');
      }

      // The response is a map where keys are category names and values are lists of wallpapers
      final Map<String, List<Wallpaper>> groupedWallpapers = {};

      json.forEach((categoryName, wallpapersList) {
        if (wallpapersList is List) {
          groupedWallpapers[categoryName] = wallpapersList
              .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
              .toList();

          if (kDebugMode) {
            print(
              'Category: $categoryName, Count: ${groupedWallpapers[categoryName]!.length}',
            );
          }
        }
      });

      if (kDebugMode) {
        print('Total categories: ${groupedWallpapers.length}');
        print('═══════════════════════════════════════════════════════════');
        print('=== FETCH GROUPED WALLPAPERS API: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }

      return groupedWallpapers;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error in fetchGroupedWallpapers API call');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is ApiException) {
          print('Status code: ${e.statusCode}');
          print('Message: ${e.message}');
        }
        print('--- Stack Trace ---');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
        print('=== FETCH GROUPED WALLPAPERS API: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }

  /// Fetch available styles from the API
  /// Returns a map where keys are style names and values are style suffixes
  Future<Map<String, String>> fetchStyles({required String accessToken}) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════════');
      print('=== FETCH STYLES API: START ===');
      print('═══════════════════════════════════════════════════════════');
      print('Endpoint: GET ${ApiConstants.wallpapersStyles}');
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    try {
      final json = await _apiService.get(
        ApiConstants.wallpapersStyles,
        headers: headers,
      );

      if (kDebugMode) {
        print('✅ Response received successfully');
        print('Response type: ${json.runtimeType}');
        print('Response keys: ${json.keys.toList()}');
      }

      // The response is a map where keys are style names and values are style suffixes
      final Map<String, String> styles = {};

      json.forEach((styleName, styleSuffix) {
        if (styleSuffix is String) {
          styles[styleName] = styleSuffix;
        }
      });

      if (kDebugMode) {
        print('Total styles: ${styles.length}');
        print('Styles: ${styles.keys.toList()}');
        print('═══════════════════════════════════════════════════════════');
        print('=== FETCH STYLES API: SUCCESS ===');
        print('═══════════════════════════════════════════════════════════');
      }

      return styles;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error in fetchStyles API call');
        print('Error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is ApiException) {
          print('Status code: ${e.statusCode}');
          print('Message: ${e.message}');
        }
        print('--- Stack Trace ---');
        print(stackTrace);
        print('═══════════════════════════════════════════════════════════');
        print('=== FETCH STYLES API: ERROR ===');
        print('═══════════════════════════════════════════════════════════');
      }
      rethrow;
    }
  }
}
