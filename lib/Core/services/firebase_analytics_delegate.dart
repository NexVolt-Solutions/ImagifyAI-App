import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';

/// Sends analytics events to Firebase. Call after [Firebase.initializeApp()]:
/// ```dart
/// await Firebase.initializeApp();
/// AnalyticsService.delegate = FirebaseAnalyticsDelegate();
/// ```
class FirebaseAnalyticsDelegate extends AppAnalyticsDelegate {
  FirebaseAnalyticsDelegate([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  void logEvent(String name, [Map<String, Object?>? params]) {
    _analytics.logEvent(
      name: name,
      parameters: params != null ? _toStringMap(params) : null,
    );
  }

  /// Firebase requires String values for parameters.
  static Map<String, String>? _toStringMap(Map<String, Object?> params) {
    final result = <String, String>{};
    for (final e in params.entries) {
      if (e.value != null) result[e.key] = e.value.toString();
    }
    return result.isEmpty ? null : result;
  }
}
