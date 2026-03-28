class AnalyticsEvents {
  AnalyticsEvents._();

  // Use app_ prefix to avoid Firebase reserved names (session_start, session_end are reserved)
  static const String sessionStart = 'app_session_start';
  static const String sessionEnd = 'app_session_end';
  static const String imageGenerated = 'image_generated';
  static const String styleSelected = 'style_selected';
  static const String imageShared = 'image_shared';
}

/// Parameter keys for analytics events.
class AnalyticsParams {
  AnalyticsParams._();

  static const String durationSeconds = 'duration_seconds';
  static const String sessionImageCount = 'session_image_count';
  static const String totalImageCount = 'total_image_count';
  static const String styleName = 'style_name';
  static const String isNewStyle = 'is_new_style';
}

/// Implement this with Firebase Analytics, AppsFlyer, or your backend.
/// Set [AnalyticsService.delegate] in main() or after app init.
abstract class AppAnalyticsDelegate {
  void logEvent(String name, [Map<String, Object?>? params]);
}

/// Retention & engagement analytics. Tracks session length, images per session,
/// and style exploration so you can trigger review/share prompts or unlock achievements.
///
/// Set [delegate] to a Firebase/AppsFlyer implementation to send events.
/// If delegate is null, events are no-op (in-memory session state still updated for future use).
class AnalyticsService {
  AnalyticsService._();

  static AppAnalyticsDelegate? delegate;

  static DateTime? _sessionStart;
  static int _sessionImageCount = 0;

  /// Call when app comes to foreground (e.g. [AppLifecycleState.resumed]).
  /// Resets session image count and logs [AnalyticsEvents.sessionStart].
  static void startSession() {
    _sessionStart = DateTime.now();
    _sessionImageCount = 0;
    _log(AnalyticsEvents.sessionStart, null);
  }

  /// Call when app goes to background (e.g. [AppLifecycleState.paused/inactive]).
  /// Logs [AnalyticsEvents.sessionEnd] with [AnalyticsParams.durationSeconds].
  static void endSession() {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!).inSeconds;
      _log(AnalyticsEvents.sessionEnd, {
        AnalyticsParams.durationSeconds: duration,
      });
      _sessionStart = null;
    }
  }

  /// Call after each successful image generation.
  /// [totalCount] = total generations ever (from InAppReviewService or your store).
  /// Logs [AnalyticsEvents.imageGenerated] with session count and total → use to trigger review/share.
  static void logImageGenerated(int totalCount) {
    _sessionImageCount++;
    _log(AnalyticsEvents.imageGenerated, {
      AnalyticsParams.sessionImageCount: _sessionImageCount,
      AnalyticsParams.totalImageCount: totalCount,
    });
  }

  /// Call when user selects a style. [isNewStyle] = first time trying this style.
  /// Logs [AnalyticsEvents.styleSelected] → use for "new style exploration" review trigger.
  static void logStyleSelected(String styleName, bool isNewStyle) {
    _log(AnalyticsEvents.styleSelected, {
      AnalyticsParams.styleName: styleName,
      AnalyticsParams.isNewStyle: isNewStyle,
    });
  }

  /// Call when user shares an image. Use to trigger review for highly engaged users.
  static void logImageShared() {
    _log(AnalyticsEvents.imageShared, null);
  }

  /// Raw event log. Use for custom events (e.g. achievements, screen views).
  static void logEvent(String name, [Map<String, Object?>? params]) {
    _log(name, params);
  }

  /// Current session image count (for triggers: e.g. prompt review if >= 2 this session).
  static int get sessionImageCount => _sessionImageCount;

  /// Whether a session is active (started and not yet ended).
  static bool get isSessionActive => _sessionStart != null;

  static void _log(String name, Map<String, Object?>? params) {
    delegate?.logEvent(name, params);
  }
}
