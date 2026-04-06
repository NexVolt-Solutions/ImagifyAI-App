import 'package:imagifyai/models/wallpaper/suggest_response.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

/// Domain contract for wallpaper operations.
/// Implemented by [WallpaperRepository] in the data layer.
abstract class IWallpaperRepository {
  Future<SuggestResponse> suggestPrompt({
    required String prompt,
    required String accessToken,
  });

  Future<List<Wallpaper>> fetchWallpapers({
    required String accessToken,
    int page = 1,
    int limit = 10,
  });

  Future<Wallpaper> createWallpaper({
    required String prompt,
    required String size,
    required String style,
    String? title,
    String? aiModel,
    required String accessToken,
  });

  Future<Wallpaper?> getWallpaperById({
    required String wallpaperId,
    required String accessToken,
  });

  Future<Wallpaper> recreateWallpaper({
    required String wallpaperId,
    required String accessToken,
    String? prompt,
    String? size,
    String? style,
  });

  Future<Wallpaper> downloadWallpaper({
    required String wallpaperId,
    required String accessToken,
  });

  Future<void> deleteWallpaper({
    required String wallpaperId,
    required String accessToken,
  });

  Future<Map<String, List<Wallpaper>>> fetchGroupedWallpapers({
    required String accessToken,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, String>> fetchStyles({required String accessToken});
}
