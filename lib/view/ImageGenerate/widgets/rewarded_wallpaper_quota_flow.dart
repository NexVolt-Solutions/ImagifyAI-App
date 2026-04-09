import 'package:flutter/material.dart';
import 'package:imagifyai/Core/services/rewarded_ad_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/services/wallpaper_usage_poll.dart';
import 'package:imagifyai/Core/utils/jwt_decoder.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:imagifyai/domain/repositories/auth_repository.dart';
import 'package:imagifyai/viewModel/image_generate_view_model.dart';
import 'package:imagifyai/viewModel/sign_in_view_model.dart';
import 'package:provider/provider.dart';

class RewardedWallpaperQuotaFlow {
  RewardedWallpaperQuotaFlow._();

  static Future<void> runWatchAdUnlockSequence({
    required BuildContext context,
    required Future<void> Function() onUnlocked,

    BuildContext? dialogToDismissOnReward,
  }) async {
    final signIn = context.read<SignInViewModel>();
    await signIn.ensureTokensLoaded();
    await signIn.ensureAccessTokenFresh();
    if (!context.mounted) return;

    var token = signIn.accessToken;
    if (token == null || token.isEmpty) {
      try {
        token = await TokenStorageService.getAccessToken();
      } catch (_) {}
    }
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        SnackbarUtil.showTopSnackBar(
          context,
          'Sign in to earn more generations.',
          isError: true,
        );
      }
      return;
    }

    var userId = await TokenStorageService.getUserId();
    userId ??= JwtDecoder.getUserId(token);
    if (userId == null || userId.isEmpty) {
      if (context.mounted) {
        SnackbarUtil.showTopSnackBar(
          context,
          'Could not verify your account for rewards.',
          isError: true,
        );
      }
      return;
    }

    void dismissPromoDialogIfOpen() {
      final d = dialogToDismissOnReward;
      if (d != null && d.mounted) {
        Navigator.of(d, rootNavigator: true).pop();
      }
    }

    final auth = AuthRepository();
    final shown = await RewardedAdService.showRewardedAd(
      serverSideVerificationUserId: userId,
      onFullscreenAdEnded: dialogToDismissOnReward != null
          ? dismissPromoDialogIfOpen
          : null,
      onReward: () async {
        dismissPromoDialogIfOpen();
        final vm = context.read<ImageGenerateViewModel>();
        final polled = await WallpaperUsagePoll.waitForPositiveRemaining(
          fetchUsage: () => auth.getDailyUsage(accessToken: token!),
        );
        if (!context.mounted) return;
        await vm.loadDailyUsage(context);
        if (!context.mounted) return;
        final refreshed = vm.dailyUsage;
        final unlocked =
            (polled != null && polled.remaining > 0) ||
            (refreshed != null && refreshed.remaining > 0);
        if (!unlocked) {
          SnackbarUtil.showTopSnackBar(
            context,
            'Reward is still processing. Wait a few seconds and try again.',
            isError: true,
          );
          return;
        }
        await onUnlocked();
      },
    );

    if (!context.mounted) return;
    if (!shown) {
      dismissPromoDialogIfOpen();
      SnackbarUtil.showTopSnackBar(
        context,
        'Ad not ready. Try again in a moment.',
        isError: true,
      );
    }
  }
}
