import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/app_cached_network_image.dart';
import 'package:imagifyai/Core/CustomWidget/app_loading_indicator.dart';
import 'package:imagifyai/Core/CustomWidget/full_screen_image_viewer.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/domain/repositories/wallpaper_repository.dart';
import 'package:imagifyai/models/wallpaper/wallpaper.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final List<Wallpaper> wallpapers;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryName,
    required this.wallpapers,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final WallpaperRepository _wallpaperRepository = WallpaperRepository();
  final ScrollController _scrollController = ScrollController();
  late List<Wallpaper> _wallpapers;
  int _page = 1;
  static const int _pageSize = 10;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _wallpapers = List<Wallpaper>.from(widget.wallpapers);
    _scrollController.addListener(_onScroll);
    _loadInitialPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        !_hasMore ||
        _isLoading) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  Future<void> _loadInitialPage() async {
    try {
      _accessToken = await TokenStorageService.getAccessToken();
      if (_accessToken == null || _accessToken!.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }
      await _fetchPage(reset: true);
    } on ApiException {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadNextPage() async {
    await _fetchPage(reset: false);
  }

  Future<void> _onRefresh() async {
    await _fetchPage(reset: true);
  }

  Future<void> _fetchPage({required bool reset}) async {
    if (_accessToken == null || _accessToken!.isEmpty) return;
    if (!reset && (_isLoadingMore || !_hasMore)) return;

    if (mounted) {
      setState(() {
        if (reset) {
          _isLoading = true;
          _page = 1;
          _hasMore = true;
        } else {
          _isLoadingMore = true;
        }
      });
    }

    try {
      final grouped = await _wallpaperRepository.fetchGroupedWallpapers(
        accessToken: _accessToken!,
        page: _page,
        limit: _pageSize,
      );
      final pageItems = grouped[widget.categoryName] ?? const <Wallpaper>[];

      if (!mounted) return;
      setState(() {
        if (reset) {
          _wallpapers = pageItems;
        } else {
          final existingIds = _wallpapers.map((e) => e.id).toSet();
          final newItems = pageItems
              .where((e) => !existingIds.contains(e.id))
              .toList();
          _wallpapers.addAll(newItems);
        }
        _hasMore = pageItems.length == _pageSize;
        if (_hasMore) {
          _page += 1;
        }
      });
    } on ApiException {
      // Keep old list on error.
    } catch (_) {
      // Keep old list on error.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName,
          style: context.appTextStyles?.homeAlignText,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: AppLoadingIndicator.large())
            : _wallpapers.isEmpty
            ? RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: context.h(60),
                            color: context.subtitleColor.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: context.h(12)),
                          Text(
                            'No wallpapers available',
                            style: context.appTextStyles?.homeCardTitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _onRefresh,
                child: GridView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(context.h(20)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.w(12),
                    mainAxisSpacing: context.h(12),
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _wallpapers.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _wallpapers.length) {
                      return Container(
                        alignment: Alignment.center,
                        child: const AppLoadingIndicator.medium(),
                      );
                    }
                    final wallpaper = _wallpapers[index];
                    final imageUrl = wallpaper.imageUrl.isNotEmpty
                        ? wallpaper.imageUrl
                        : (wallpaper.thumbnailUrl.isNotEmpty
                              ? wallpaper.thumbnailUrl
                              : null);

                    if (imageUrl == null || imageUrl.isEmpty) {
                      return Container(
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(
                            context.radius(12),
                          ),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: context.subtitleColor,
                          size: 40,
                        ),
                      );
                    }

                    final dpr = MediaQuery.devicePixelRatioOf(context);
                    final sw = MediaQuery.sizeOf(context).width;
                    final gridPad = context.h(20) * 2;
                    final crossGap = context.w(12);
                    final cellLogicalW = (sw - gridPad - crossGap) / 2;
                    final cellLogicalH = cellLogicalW / 0.75;
                    final gridCacheW = (cellLogicalW * dpr).round().clamp(
                      64,
                      4096,
                    );
                    final gridCacheH = (cellLogicalH * dpr).round().clamp(
                      64,
                      4096,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageViewer(
                              imageUrl: imageUrl,
                              heroTag: 'category_${wallpaper.id}_$index',
                              wallpaper: wallpaper,
                              previewBackdropCacheWidth: gridCacheW,
                              previewBackdropCacheHeight: gridCacheH,
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'category_${wallpaper.id}_$index',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              context.radius(12),
                            ),
                            border: Border.all(
                              color: context.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: AppCachedNetworkImage(
                            imageUrl: imageUrl,
                            useGradientPlaceholder: false,
                            placeholderBackgroundColor: context.surfaceColor,
                            errorWidget: (context, _, __) {
                              return Container(
                                color: context.surfaceColor,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: context.subtitleColor,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
