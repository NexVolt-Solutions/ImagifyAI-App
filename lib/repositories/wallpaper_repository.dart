import 'package:genwalls/Core/Constants/api_constants.dart';
import 'package:genwalls/Core/services/api_service.dart';
import 'package:genwalls/models/wallpaper/suggest_response.dart';
import 'package:genwalls/models/wallpaper/wallpaper.dart';

class WallpaperRepository {
  WallpaperRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<SuggestResponse> suggestPrompt({required String prompt}) async {
    final json = await _apiService.post(
      ApiConstants.suggestPrompt,
      body: {'prompt': prompt},
    );
    return SuggestResponse.fromJson(json);
  }

  Future<List<Wallpaper>> fetchWallpapers() async {
    final json = await _apiService.get(ApiConstants.wallpapers);
    final list = (json['wallpapers'] as List?) ?? [];
    return list.map((e) => Wallpaper.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Wallpaper> createWallpaper({
    required String prompt,
    required String size,
    required String style,
    required String title,
    required String aiModel,
  }) async {
    final json = await _apiService.post(
      ApiConstants.wallpapers,
      body: {
        'prompt': prompt,
        'size': size,
        'style': style,
        'title': title,
        'ai_model': aiModel,
      },
    );
    return Wallpaper.fromJson(json);
  }

  Future<Wallpaper> recreateWallpaper({required String wallpaperId}) async {
    final path = '${ApiConstants.recreateWallpaper}/$wallpaperId/recreate';
    final json = await _apiService.post(path);
    return Wallpaper.fromJson(json);
  }

  Future<Wallpaper> downloadWallpaper({required String wallpaperId}) async {
    final path = '${ApiConstants.downloadWallpaper}/$wallpaperId/download';
    final json = await _apiService.get(path);
    return Wallpaper.fromJson(json);
  }
}

