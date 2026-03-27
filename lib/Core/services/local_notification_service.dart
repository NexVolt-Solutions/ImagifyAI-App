import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:imagifyai/Core/services/secure_storage_helper.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Local reminders: (1) optional review nudge once ~3 days after first open,
/// (2) repeating daily return ping at a fixed local time (see [_dailyReminderHour])
/// for signed-in users who keep retention reminders on.
class LocalNotificationService {
  LocalNotificationService._();

  static const String _keyReviewReminderScheduled =
      'local_notif_review_reminder_scheduled';
  static const String _keyDailyReturnLastScheduleMs =
      'local_notif_daily_return_last_schedule_ms';
  static const String _keyRetentionRemindersEnabled =
      'prefs_retention_reminders_enabled';
  static const String _keyRetentionRemindersLegacyMigrated =
      'prefs_retention_reminders_legacy_migrated_v1';
  static const int _reviewReminderId = 1;
  static const int _dailyReturnId = 2;
  /// Local wall-clock time for the repeating daily return nudge (device timezone).
  static const int _dailyReminderHour = 10;
  static const int _dailyReminderMinute = 0;
  static const String _channelId = 'imagifyai_reminders';
  static const String _channelName = 'Reminders';
  /// Separate channel so daily return pings can use default importance (review uses low).
  static const String _dailyChannelId = 'imagifyai_daily_return';
  static const String _dailyChannelName = 'Daily reminders';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static Future<void>? _prefsMigrationFuture;

  static Future<void> _migrateNotificationKeysFromSharedPreferences() async {
    _prefsMigrationFuture ??= _runNotificationPrefsMigration();
    await _prefsMigrationFuture;
  }

  static Future<void> _runNotificationPrefsMigration() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Future<void> migrateBool(String key) async {
        if (await SecureStorageHelper.read(key) != null) {
          if (prefs.containsKey(key)) await prefs.remove(key);
          return;
        }
        if (!prefs.containsKey(key)) return;
        final v = prefs.getBool(key) ?? false;
        await SecureStorageHelper.writeBool(key, v);
        await prefs.remove(key);
      }

      Future<void> migrateInt(String key) async {
        if (await SecureStorageHelper.read(key) != null) {
          if (prefs.containsKey(key)) await prefs.remove(key);
          return;
        }
        if (!prefs.containsKey(key)) return;
        final v = prefs.getInt(key);
        if (v != null) await SecureStorageHelper.writeInt(key, v);
        await prefs.remove(key);
      }

      await migrateBool(_keyReviewReminderScheduled);
      await migrateBool(_keyRetentionRemindersEnabled);
      await migrateBool(_keyRetentionRemindersLegacyMigrated);
      await migrateInt(_keyDailyReturnLastScheduleMs);
    } catch (_) {}
  }

  /// Call from main() after WidgetsFlutterBinding.ensureInitialized().
  /// Initializes the plugin and timezone data for scheduling.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _migrateNotificationKeysFromSharedPreferences();
      tz_data.initializeTimeZones();
      await _configureDeviceTimeZone();
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
    } catch (e) {
      // init failed
    }
  }

  /// Request permission to show notifications (iOS, Android 13+).
  /// Android 12+: exact daily time needs SCHEDULE_EXACT_ALARM + user opt-in on some OS versions.
  static Future<void> _ensureAndroidExactAlarmIfNeeded() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    try {
      final can = await android.canScheduleExactNotifications();
      if (can == true) return;
      await android.requestExactAlarmsPermission();
    } catch (_) {}
  }

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
      return false;
    }
  }

  /// Schedule a gentle review reminder in [daysFromNow] (default 3) if we haven't
  /// already scheduled one and the user hasn't been asked for review yet.
  static Future<void> scheduleReviewReminderIfEligible({
    int daysFromNow = 3,
    String title = 'Enjoying imagifyai?',
    String body = 'Your feedback helps us improve. Tap to rate the app.',
    Future<bool> Function()? hasRequestedReview,
  }) async {
    try {
      await _migrateNotificationKeysFromSharedPreferences();
      if ((await SecureStorageHelper.readBool(_keyReviewReminderScheduled)) ==
          true) {
        return;
      }
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

      await SecureStorageHelper.writeBool(_keyReviewReminderScheduled, true);
    } catch (e) {
      // schedule failed
    }
  }

  /// Align package [tz] “local” with the device IANA zone for correct schedules.
  static Future<void> _configureDeviceTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.UTC);
      } catch (_) {}
    }
  }

  /// User preference (Profile → Notifications). New installs default to **on**.
  ///
  /// One-time migration: if a legacy schedule existed, keep reminders **on**.
  static Future<bool> areRetentionRemindersEnabled() async {
    await _migrateNotificationKeysFromSharedPreferences();
    final enabledRaw =
        await SecureStorageHelper.read(_keyRetentionRemindersEnabled);
    if (enabledRaw != null) {
      return enabledRaw == 'true';
    }
    final legacyDone =
        await SecureStorageHelper.readBool(_keyRetentionRemindersLegacyMigrated) ??
            false;
    if (!legacyDone) {
      final defaultOn = true;
      await SecureStorageHelper.writeBool(
        _keyRetentionRemindersLegacyMigrated,
        true,
      );
      await SecureStorageHelper.writeBool(
        _keyRetentionRemindersEnabled,
        defaultOn,
      );
      return defaultOn;
    }
    // Preference missing after migration: default to ON.
    await SecureStorageHelper.writeBool(_keyRetentionRemindersEnabled, true);
    return true;
  }

  /// Persists opt-in/out and cancels any pending return nudge when disabled.
  static Future<void> setRetentionRemindersEnabled(bool enabled) async {
    await _migrateNotificationKeysFromSharedPreferences();
    await SecureStorageHelper.writeBool(_keyRetentionRemindersEnabled, enabled);
    if (!enabled) {
      await cancelDailyReturnNudge();
    }
  }

  /// Cancels the “daily return” nudge and clears reschedule debounce state.
  static Future<void> cancelDailyReturnNudge() async {
    try {
      await _plugin.cancel(_dailyReturnId);
      await _migrateNotificationKeysFromSharedPreferences();
      await SecureStorageHelper.delete(_keyDailyReturnLastScheduleMs);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_keyDailyReturnLastScheduleMs);
      } catch (_) {}
    } catch (_) {}
  }

  /// Repeating **daily** local notification at [_dailyReminderHour]:[_dailyReminderMinute]
  /// (device timezone). Same notification id is re-registered on each eligible call
  /// so time zone changes are picked up after resume. Requires signed-in session.
  static Future<void> rescheduleDailyReturnNudgeIfEligible({
    String title = 'Imagify AI',
    String body =
        'Your free generations renew each day — tap to create a new wallpaper.',
    Duration rescheduleDebounce = const Duration(minutes: 5),
    bool ignoreDebounce = false,
  }) async {
    if (!_initialized) return;
    try {
      if (!await areRetentionRemindersEnabled()) {
        await cancelDailyReturnNudge();
        return;
      }

      final access = await TokenStorageService.getAccessToken();
      if (access == null || access.isEmpty) {
        await cancelDailyReturnNudge();
        return;
      }

      await _migrateNotificationKeysFromSharedPreferences();
      final lastMs =
          await SecureStorageHelper.readInt(_keyDailyReturnLastScheduleMs) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (!ignoreDebounce &&
          nowMs - lastMs < rescheduleDebounce.inMilliseconds) {
        return;
      }
      await SecureStorageHelper.writeInt(_keyDailyReturnLastScheduleMs, nowMs);

      final granted = await requestPermission();
      if (!granted) return;

      await _ensureAndroidExactAlarmIfNeeded();

      await _plugin.cancel(_dailyReturnId);

      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        _dailyReminderHour,
        _dailyReminderMinute,
      );
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          channelDescription: 'Daily return reminder at a fixed local time',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: false),
      );

      await _plugin.zonedSchedule(
        _dailyReturnId,
        title,
        body,
        next,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  static Future<void> cancelReviewReminder() async {
    try {
      await _plugin.cancel(_reviewReminderId);
      await _migrateNotificationKeysFromSharedPreferences();
      await SecureStorageHelper.writeBool(_keyReviewReminderScheduled, false);
    } catch (e) {
      // cancel failed
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
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _dailyChannelId,
          _dailyChannelName,
          description: 'Daily return reminder',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Optionally: navigate to rate screen or open in-app review when user taps.
  }
}
