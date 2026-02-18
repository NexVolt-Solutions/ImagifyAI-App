import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Gentle reminders for review or Pro features. Schedules at most one review
/// reminder (e.g. 3 days after first open) if the user hasn't been prompted yet.
class LocalNotificationService {
  LocalNotificationService._();

  static const String _keyReviewReminderScheduled =
      'local_notif_review_reminder_scheduled';
  static const int _reviewReminderId = 1;
  static const String _channelId = 'imagifyai_reminders';
  static const String _channelName = 'Reminders';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Call from main() after WidgetsFlutterBinding.ensureInitialized().
  /// Initializes the plugin and timezone data for scheduling.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
      final android = AndroidInitializationSettings('@mipmap/ic_launcher');
      final ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
      );
      await _plugin.initialize(
        InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      await _createChannel();
      _initialized = true;
      if (kDebugMode) print('LocalNotificationService: initialized');
    } catch (e) {
      if (kDebugMode) print('LocalNotificationService init: $e');
    }
  }

  /// Request permission to show notifications (iOS, Android 13+).
  static Future<bool> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true);
        return granted ?? false;
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('LocalNotificationService requestPermission: $e');
      return false;
    }
  }

  /// Schedule a gentle review reminder in [daysFromNow] (default 3) if we haven't
  /// already scheduled one and the user hasn't been asked for review yet.
  /// Call after recording first open; uses SharedPreferences to avoid duplicate scheduling.
  static Future<void> scheduleReviewReminderIfEligible({
    int daysFromNow = 3,
    String title = 'Enjoying imagifyai?',
    String body = 'Your feedback helps us improve. Tap to rate the app.',
    Future<bool> Function()? hasRequestedReview,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewReminderScheduled) == true) return;
      if (hasRequestedReview != null && await hasRequestedReview()) return;

      final granted = await requestPermission();
      if (!granted) return;

      final now = tz.TZDateTime.now(tz.local);
      final scheduled = now.add(Duration(days: daysFromNow));

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Gentle reminders for review and tips',
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: false),
      );

      await _plugin.zonedSchedule(
        _reviewReminderId,
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      await prefs.setBool(_keyReviewReminderScheduled, true);
      if (kDebugMode)
        print(
          'LocalNotificationService: review reminder scheduled in $daysFromNow days',
        );
    } catch (e) {
      if (kDebugMode)
        print('LocalNotificationService scheduleReviewReminder: $e');
    }
  }

  /// Cancel the scheduled review reminder.
  static Future<void> cancelReviewReminder() async {
    try {
      await _plugin.cancel(_reviewReminderId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyReviewReminderScheduled, false);
    } catch (e) {
      if (kDebugMode)
        print('LocalNotificationService cancelReviewReminder: $e');
    }
  }

  static Future<void> _createChannel() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Gentle reminders for review and Pro features',
          importance: Importance.low,
        ),
      );
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode)
      print('LocalNotificationService: notification tapped ${response.id}');
    // Optionally: navigate to rate screen or open in-app review when user taps.
  }
}
