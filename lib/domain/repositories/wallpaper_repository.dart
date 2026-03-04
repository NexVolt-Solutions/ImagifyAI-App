import 'dart:convert';
import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository_interface.dart';
import 'package:imagifyai/models/wallpaper/suggest_response.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

class WallpaperRepository implements IWallpaperRepository {
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
      throw ApiException(
        'Invalid response: wallpapers field missing',
        statusCode: 500,
      );
    }

    final list = json['wallpapers'] as List;
    final wallpapers = list
        .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
        .toList();
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

    try {
      final json = await _apiService.post(
        ApiConstants.wallpapers,
        body: body,
        headers: headers,
      );
      return Wallpaper.fromJson(json);
    } catch (e, stackTrace) {
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

    try {
      // Backend doesn't support GET /wallpapers/{id}
      // So we fetch the list and find the wallpaper by ID
      final json = await _apiService.get(
        ApiConstants.wallpapers,
        headers: headers,
      );

      if (!json.containsKey('wallpapers')) {
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
        return null;
      }
      return Wallpaper.fromJson(wallpaperMap);
    } catch (e, stackTrace) {
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

    final path = '${ApiConstants.recreateWallpaper}/$wallpaperId/recreate';
    final json = await _apiService.post(
      path,
      headers: headers,
      body: body.isNotEmpty ? body : null,
    );
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

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    // Add query parameter to exclude user-specific wallpapers
    // The backend should return general wallpapers for all users
    final queryParams = <String, String>{
      'public': 'true', // Request public/general wallpapers only
      'page': page.toString(),
      'limit': limit.toString(),
    };

    try {
      final json = await _apiService.get(
        ApiConstants.groupedWallpapers,
        headers: headers,
        query: queryParams,
      );

      final Map<String, List<Wallpaper>> groupedWallpapers = {};
      json.forEach((categoryName, wallpapersList) {
        if (wallpapersList is List) {
          groupedWallpapers[categoryName] = wallpapersList
              .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
      return groupedWallpapers;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Fetch available styles from the API
  /// Returns a map where keys are style names and values are style suffixes
  Future<Map<String, String>> fetchStyles({required String accessToken}) async {
    if (accessToken.isEmpty) {
      throw ApiException('Access token is required', statusCode: 401);
    }

    final headers = <String, String>{'Authorization': 'Bearer $accessToken'};

    try {
      final json = await _apiService.get(
        ApiConstants.wallpapersStyles,
        headers: headers,
      );

      final Map<String, String> styles = {};
      json.forEach((styleName, styleSuffix) {
        if (styleSuffix is String) {
          styles[styleName] = styleSuffix;
        }
      });
      return styles;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
