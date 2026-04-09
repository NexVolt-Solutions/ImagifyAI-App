import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';

class FirebaseAnalyticsDelegate extends AppAnalyticsDelegate {
  FirebaseAnalyticsDelegate([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  void logEvent(String name, [Map<String, Object?>? params]) {
    final stringMap = params != null ? _toStringMap(params) : null;
    if (stringMap != null && stringMap.isNotEmpty) {
      _analytics.logEvent(name: name, parameters: stringMap);
    } else {
      // Omit parameters so web SDK does not log `null` for missing payload.
      _analytics.logEvent(name: name);
    }
  }

  static Map<String, String>? _toStringMap(Map<String, Object?> params) {
    final result = <String, String>{};
    for (final e in params.entries) {
      if (e.value != null) result[e.key] = e.value.toString();
    }
    return result.isEmpty ? null : result;
  }
}
