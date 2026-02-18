import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewService {
  static const String _keyFirstOpenDate = 'in_app_review_first_open_date';
  static const String _keyCompletedGenerations =
      'in_app_review_completed_generations';
  static const String _keyReviewRequested = 'in_app_review_requested';
  static const String _keyTriedStyles = 'in_app_review_tried_styles';
  static const String _keyAppOpenCount = 'in_app_review_app_open_count';

  /// Adaptive milestones: request review when generation count hits any of these.
  static const List<int> generationMilestones = [2, 5, 10];

  static const int daysThreshold = 5;

  /// Ensures only active, engaged users get the time-based review prompt → better ratings.
  static const int minGenerationsForTimeTrigger = 3;

  static const int appOpenMilestone = 7;

  /// App name shown in the soft feedback dialog.
  static const String appDisplayName = 'imagifyai';

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Shows "Do you like [app]?" dialog. Returns true if Yes, false if No, null if dismissed.
  /// Call before requesting Play Store review; only request when true → reduces 1-star reviews.
  static Future<bool?> showSoftFeedbackDialog(BuildContext context) async {
    if (!context.mounted) return null;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Do you like $appDisplayName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  /// Requests the Play Store in-app review if not already requested and API is available.
  /// Call this after user answers "Yes" to the soft feedback dialog.
  static Future<void> requestReviewIfEligible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;
      if (!await _inAppReview.isAvailable()) return;
      await prefs.setBool(_keyReviewRequested, true);
      await _inAppReview.requestReview();
      if (kDebugMode) print('InAppReview: requested (after soft feedback yes)');
    } catch (e) {
      if (kDebugMode) print('InAppReview requestReviewIfEligible: $e');
    }
  }

  /// Whether we've already requested the in-app review (for notification reminder eligibility).
  static Future<bool> hasRequestedReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyReviewRequested) == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns total completed image generations (for analytics / session triggers).
  static Future<int> getCompletedGenerationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyCompletedGenerations) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Records first open date so we can trigger after 5 days. Does not show review.
  static Future<void> recordFirstOpenIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_keyFirstOpenDate) != null) return;
      await prefs.setString(
        _keyFirstOpenDate,
        DateTime.now().toIso8601String(),
      );
      if (kDebugMode) {
        print('InAppReview: first open date recorded');
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview recordFirstOpen: $e');
    }
  }

  /// Call after each successful image generation.
  /// At milestones (2, 5, 10): shows soft feedback dialog if [context] provided; only requests store review if user says Yes.
  static Future<void> recordCompletedGenerationAndMaybeReview([
    BuildContext? context,
  ]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;

      int count = prefs.getInt(_keyCompletedGenerations) ?? 0;
      count++;
      await prefs.setInt(_keyCompletedGenerations, count);

      if (kDebugMode) {
        print('InAppReview: completed generations = $count');
      }

      AnalyticsService.logImageGenerated(count);

      final isMilestone = generationMilestones.contains(count);
      if (isMilestone && await _inAppReview.isAvailable()) {
        if (context != null && context.mounted) {
          final liked = await showSoftFeedbackDialog(context);
          if (liked == true) await requestReviewIfEligible();
        } else {
          await prefs.setBool(_keyReviewRequested, true);
          await _inAppReview.requestReview();
          if (kDebugMode)
            print('InAppReview: requested at milestone $count generations');
        }
        return;
      }

      // Session-based: 2+ images this session → trigger review/share prompt (retention hook).
      if (AnalyticsService.sessionImageCount >= 2 &&
          await _inAppReview.isAvailable() &&
          context != null &&
          context.mounted) {
        final liked = await showSoftFeedbackDialog(context);
        if (liked == true) await requestReviewIfEligible();
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview recordCompletedGeneration: $e');
    }
  }

  /// Time + engagement: only prompt when 5+ days since first open AND 3+ generations.
  /// Ensures only active, engaged users get the time-based review prompt → better ratings.
  static Future<void> checkFiveDayAndMaybeReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;

      final firstOpenStr = prefs.getString(_keyFirstOpenDate);
      if (firstOpenStr == null) return; // first open not recorded yet

      final firstOpen = DateTime.tryParse(firstOpenStr);
      if (firstOpen == null) return;

      final daysSinceFirstOpen = DateTime.now().difference(firstOpen).inDays;
      if (daysSinceFirstOpen < daysThreshold) return;

      final generationCount = prefs.getInt(_keyCompletedGenerations) ?? 0;
      if (generationCount < minGenerationsForTimeTrigger) return;

      if (!await _inAppReview.isAvailable()) return;

      await prefs.setBool(_keyReviewRequested, true);
      await _inAppReview.requestReview();
      if (kDebugMode) {
        print(
          'InAppReview: requested after $daysSinceFirstOpen days + $generationCount generations',
        );
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview checkFiveDay: $e');
    }
  }

  /// shows soft feedback if [context] provided; only requests store review if user says Yes.
  static Future<void> recordStyleTriedAndMaybeReview(
    String styleName, [
    BuildContext? context,
  ]) async {
    if (styleName.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;

      final tried = prefs.getStringList(_keyTriedStyles) ?? [];
      if (tried.contains(styleName)) return;

      tried.add(styleName);
      await prefs.setStringList(_keyTriedStyles, tried);

      AnalyticsService.logStyleSelected(styleName, true);

      if (kDebugMode) {
        print(
          'InAppReview: new style tried "$styleName" (total ${tried.length})',
        );
      }

      if (!await _inAppReview.isAvailable()) return;

      if (context != null && context.mounted) {
        final liked = await showSoftFeedbackDialog(context);
        if (liked == true) await requestReviewIfEligible();
      } else {
        await prefs.setBool(_keyReviewRequested, true);
        await _inAppReview.requestReview();
        if (kDebugMode) print('InAppReview: requested after trying new style');
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview recordStyleTried: $e');
    }
  }

  /// Call after the user successfully shares an image. Shows soft feedback if [context] provided.
  static Future<void> recordShareAndMaybeReview([BuildContext? context]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;
      if (!await _inAppReview.isAvailable()) return;

      if (context != null && context.mounted) {
        final liked = await showSoftFeedbackDialog(context);
        if (liked == true) await requestReviewIfEligible();
      } else {
        await prefs.setBool(_keyReviewRequested, true);
        await _inAppReview.requestReview();
        if (kDebugMode) print('InAppReview: requested after share');
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview recordShare: $e');
    }
  }

  /// Call when the user upgrades to Pro (if you add IAP). Paying users leave positive ratings.
  static Future<void> recordProUpgradeAndMaybeReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;
      if (!await _inAppReview.isAvailable()) return;

      await prefs.setBool(_keyReviewRequested, true);
      await _inAppReview.requestReview();
      if (kDebugMode) print('InAppReview: requested after Pro upgrade');
    } catch (e) {
      if (kDebugMode) print('InAppReview recordProUpgrade: $e');
    }
  }

  /// Call on app open/resume. Triggers review every [appOpenMilestone] opens (e.g. every 7th).
  static Future<void> recordAppOpenAndMaybeReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyReviewRequested) == true) return;

      int count = prefs.getInt(_keyAppOpenCount) ?? 0;
      count++;
      await prefs.setInt(_keyAppOpenCount, count);

      if (kDebugMode && count % appOpenMilestone == 0) {
        print(
          'InAppReview: app open count = $count (milestone $appOpenMilestone)',
        );
      }

      if (count % appOpenMilestone == 0 && await _inAppReview.isAvailable()) {
        await prefs.setBool(_keyReviewRequested, true);
        await _inAppReview.requestReview();
        if (kDebugMode) print('InAppReview: requested after $count app opens');
      }
    } catch (e) {
      if (kDebugMode) print('InAppReview recordAppOpen: $e');
    }
  }
}
