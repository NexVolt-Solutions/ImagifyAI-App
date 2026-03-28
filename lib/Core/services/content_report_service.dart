import 'package:flutter/material.dart';
import 'package:imagifyai/Core/Constants/api_constants.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/services/api_service.dart';
import 'package:imagifyai/Core/services/analytics_service.dart';
import 'package:imagifyai/Core/services/token_storage_service.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/Core/utils/snackbar_util.dart';
import 'package:url_launcher/url_launcher.dart';

/// Report reasons for AI-generated content (Google Play AI-Generated Content policy compliance).
class ReportReason {
  const ReportReason(this.id, this.label);

  final String id;
  final String label;

  static const List<ReportReason> reasons = [
    ReportReason('offensive', 'Offensive or inappropriate content'),
    ReportReason('violence', 'Violence or graphic content'),
    ReportReason('hate', 'Hate speech or discrimination'),
    ReportReason('sexual', 'Sexually explicit content'),
    ReportReason('other', 'Other'),
  ];
}

/// Service for reporting/flagging offensive AI-generated content.
/// Required for Google Play AI-Generated Content policy compliance.
class ContentReportService {
  ContentReportService._();

  static const String _supportEmail = 'support@imagifyai.com';

  /// Shows info dialog explaining where users can report. Call from Profile or Create screen.
  static void showReportInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final primaryColor = Theme.of(ctx).colorScheme.primary;
        final textColor = Theme.of(ctx).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
        final bgColor = Theme.of(ctx).scaffoldBackgroundColor;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.flag_outlined, color: primaryColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Report offensive content',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          content: Text(
            'To report AI-generated content you find inappropriate:\n\n'
            '• When viewing a generated image: tap the Report (flag) icon or "Report content" button\n'
            '• In Explore Prompt: tap Report below any image\n'
            '• In full-screen view: tap the flag icon in the top right\n\n'
            'You can report from any AI-generated image in the app.',
            style: TextStyle(color: textColor, height: 1.8, fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Got it', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  /// Shows a report dialog for the given content. Call from Image Created or Explore Prompt screens.
  static Future<void> showReportDialog(
    BuildContext context, {
    required String contentId,
    String? imageUrl,
    String? prompt,
    String? sourceLabel,
  }) async {
    if (!context.mounted) return;

    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: context.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius(16)),
        ),
      ),
      builder: (ctx) => _ReportContentSheet(
        contentId: contentId,
        imageUrl: imageUrl,
        prompt: prompt,
        sourceLabel: sourceLabel,
      ),
    );

    if (!context.mounted || selected == null) return;

    await _submitReport(
      context,
      contentId: contentId,
      reason: selected,
      prompt: prompt,
    );
  }

  static Future<void> _submitReport(
    BuildContext context, {
    required String contentId,
    required String reason,
    String? prompt,
  }) async {
    final token = await TokenStorageService.getAccessToken();
    final headers = token != null && token.isNotEmpty
        ? {'Authorization': 'Bearer $token'}
        : null;

    try {
      // POST /api/v1/wallpapers/{wallpaper_id}/report
      final path = '${ApiConstants.reportWallpaper}/$contentId/report';
      final body = <String, String>{
        'reason': reason,
        'prompt': (prompt != null && prompt.trim().isNotEmpty)
            ? prompt.trim()
            : 'N/A',
      };
      await ApiService().post(
        path,
        headers: headers,
        body: body,
        retryOnTokenExpiry: true,
      );
      AnalyticsService.logEvent('content_reported', {
        'content_id': contentId,
        'reason': reason,
      });
      if (context.mounted) {
        SnackbarUtil.showTopSnackBar(
          context,
          'Thank you. Your report has been submitted.',
          isError: false,
        );
      }
    } catch (e) {
      // Fallback: open email client for report (ensures compliance even without backend)
      await _reportViaEmail(
        contentId: contentId,
        reason: reason,
        prompt: prompt,
      );
      AnalyticsService.logEvent('content_reported_email', {
        'content_id': contentId,
        'reason': reason,
      });
      if (context.mounted) {
        SnackbarUtil.showTopSnackBar(
          context,
          'Thank you. You can send your report via email.',
          isError: false,
        );
      }
    }
  }

  static Future<void> _reportViaEmail({
    required String contentId,
    required String reason,
    String? prompt,
  }) async {
    final subject = Uri.encodeComponent(
      '[Imagify AI] Report: Offensive Content - $contentId',
    );
    final body = Uri.encodeComponent(
      'I am reporting the following AI-generated content as inappropriate.\n\n'
      'Content ID: $contentId\n'
      'Reason: $reason\n'
      'Prompt: ${prompt ?? "N/A"}\n\n'
      '---\nPlease describe the issue in more detail below:\n',
    );
    final uri = Uri.parse('mailto:$_supportEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ReportContentSheet extends StatelessWidget {
  const _ReportContentSheet({
    required this.contentId,
    this.imageUrl,
    this.prompt,
    this.sourceLabel,
  });

  final String contentId;
  final String? imageUrl;
  final String? prompt;
  final String? sourceLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.w(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: context.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: context.w(12)),
                  SizedBox(
                    width: context.w(280),
                    child: Text(
                      'Report content',
                      style: context.appTextStyles?.profileScreenTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(8)),
              Text(
                'Help us keep Imagify AI safe. Select a reason for this report.',
                style: context.appTextStyles?.profileScreenSubtitle,
              ),
              SizedBox(height: context.h(20)),
              ...ReportReason.reasons.map(
                (r) => Padding(
                  padding: EdgeInsets.only(bottom: context.h(8)),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, r.id),
                      borderRadius: BorderRadius.circular(context.radius(12)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(16),
                          vertical: context.h(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.report_outlined,
                              color: context.subtitleColor,
                              size: 20,
                            ),
                            SizedBox(width: context.w(12)),
                            Expanded(
                              child: Text(
                                r.label,
                                style: context
                                    .appTextStyles
                                    ?.profileListItemSubtitle,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: context.subtitleColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.h(8)),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: context.subtitleColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
