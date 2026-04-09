/// Response from `GET /wallpapers/usage` (server-enforced wallpaper quota + rewarded flow).
///
/// When [requiresRewardedAd] is true and [remaining] is 0, the user must complete a
/// rewarded ad (SSV grants credits on the server); then refresh this snapshot.
class UsageResponse {
  UsageResponse({
    required this.used,
    required this.limit,
    required this.remaining,
    required this.resetsAt,
    this.requiresRewardedAd = false,
    this.initialFreeRemaining,
    this.postAdFreeRemaining,
  });

  final int used;
  final int limit;
  final int remaining;
  final DateTime resetsAt;

  /// Server says the next allowance block requires a rewarded completion (SSV).
  final bool requiresRewardedAd;

  /// Optional breakdown for UI (5 + 3 + 3 …); may be null on older APIs.
  final int? initialFreeRemaining;
  final int? postAdFreeRemaining;

  factory UsageResponse.fromJson(Map<String, dynamic> json) {
    return UsageResponse(
      used: _toInt(json['used']),
      limit: _toInt(json['limit']),
      remaining: _toInt(json['remaining']),
      resetsAt: DateTime.parse(json['resets_at'].toString()).toUtc(),
      requiresRewardedAd: _toBool(json['requires_rewarded_ad']),
      initialFreeRemaining: _toNullableInt(json['initial_free_remaining']),
      postAdFreeRemaining: _toNullableInt(json['post_ad_free_remaining']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == 'true' || s == '1';
  }

  /// No more generations for this window, even after rewarded ads (hard cap).
  bool get isHardLimitReached => remaining <= 0 && !requiresRewardedAd;

  /// Alias for older call sites: "limit reached" means hard server cap.
  bool get isLimitReached => isHardLimitReached;

  /// Must watch a rewarded ad before [remaining] can increase (SSV on server).
  bool get needsRewardedAdToContinue => remaining <= 0 && requiresRewardedAd;

  /// Countdown until [resetsAt] in UTC (e.g. "5h 23m").
  String get resetCountdown {
    final now = DateTime.now().toUtc();
    var diff = resetsAt.difference(now);
    if (diff.isNegative) diff = Duration.zero;
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

/// Server returned 429 asking the user to watch a rewarded ad (not hard daily cap).
bool isWatchAdUnlockQuotaMessage(String message) {
  final m = message.toLowerCase();
  return m.contains('watch an ad') ||
      m.contains('watch a rewarded') ||
      m.contains('unlock 3');
}

bool isDailyWallpaperLimitMessage(String message) {
  final m = message.toLowerCase();
  return m.contains('daily limit') || m.contains('daily wallpaper');
}

bool isGenericRateLimitMessage(String message) {
  final m = message.toLowerCase();
  return m.contains('rate limit') || m.contains('too many requests');
}
