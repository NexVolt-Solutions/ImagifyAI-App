import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estimates **server time** from the HTTP `Date` header so rolling windows
/// (generation limits, interstitial pacing) are not reset by changing the device clock.
///
/// [nowMs] = device clock + persisted offset. Offset updates on every API response
/// that includes `Date`, correcting forward/backward device tampering after the next request.
class ServerClock {
  ServerClock._();

  static const String _prefsKey = 'server_clock_offset_ms';

  static int _offsetMs = 0;
  static bool _prefsLoaded = false;

  static Future<void> ensureLoaded() async {
    if (_prefsLoaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      _offsetMs = p.getInt(_prefsKey) ?? 0;
    } catch (_) {}
    _prefsLoaded = true;
  }

  /// Call for every completed HTTP response that may carry a `Date` header.
  static void syncFromHttpResponse(http.Response response) {
    final raw = response.headers['date'] ?? response.headers['Date'];
    if (raw == null || raw.isEmpty) return;
    try {
      final serverUtc = parseHttpDate(raw.trim());
      final deviceMs = DateTime.now().millisecondsSinceEpoch;
      _offsetMs = serverUtc.millisecondsSinceEpoch - deviceMs;
      unawaited(_persistOffset());
    } catch (_) {}
  }

  static Future<void> _persistOffset() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_prefsKey, _offsetMs);
    } catch (_) {}
  }

  /// Best-effort “current time” in ms, aligned to the server when [syncFromHttpResponse] has run.
  static Future<int> nowMs() async {
    await ensureLoaded();
    return DateTime.now().millisecondsSinceEpoch + _offsetMs;
  }
}
