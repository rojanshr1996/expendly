import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../extensions/context_extensions.dart';
import '../models/notification_payload.dart';
import '../theme/font_weights.dart';
import 'glass_container.dart';
import 'status_components.dart';

/// Modal dialog displayed when a user taps an in-app notification
/// (for actionTypes other than externalUrl).
class NotificationDetailDialog extends StatelessWidget {
  final NotificationActionPayload payload;
  final VoidCallback? onPrimaryAction;

  const NotificationDetailDialog({
    super.key,
    required this.payload,
    this.onPrimaryAction,
  });

  /// Helper to present the dialog globally using context
  static Future<void> show(
    BuildContext context,
    NotificationActionPayload payload, {
    VoidCallback? onPrimaryAction,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => NotificationDetailDialog(
        payload: payload,
        onPrimaryAction: onPrimaryAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = payload.title ?? context.l10n.notificationAlert;
    final body = payload.body ?? '';
    final imageUrl = payload.imageUrl;
    final isBackup = title.toLowerCase().contains('backup') ||
        body.toLowerCase().contains('backup');

    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(20.r),
        backgroundColor: const Color(0xFF141C19).withValues(alpha: 0.95),
        borderStrokeColor: customColors.glassStroke,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Category + Close Button
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: (isBackup
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBackup
                        ? Icons.cloud_done_rounded
                        : Icons.notifications_active_rounded,
                    color: isBackup ? colorScheme.primary : Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBackup
                            ? l10n.systemBackupHeader
                            : l10n.notificationHeader,
                        style: textTheme.labelSmall?.copyWith(
                          color: isBackup
                              ? colorScheme.primary
                              : colorScheme.outline,
                          fontWeight: FontWeights.semiBold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeights.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: colorScheme.outline),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Optional Image Attachment
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildImage(imageUrl),
              ),
              SizedBox(height: 14.h),
            ],

            // Body Message Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: customColors.surfaceLow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: customColors.glassStroke),
              ),
              child: SelectableText(
                body.isNotEmpty ? body : l10n.noNotificationBody,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // If body contains file path or long string, offer a Copy button
                if (body.contains('/') ||
                    body.contains('\\') ||
                    body.length > 30)
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: body));
                      StatusComponents.showToast(
                        context,
                        message: l10n.contentCopied,
                        isSuccess: true,
                      );
                    },
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 16.sp,
                      color: colorScheme.outline,
                    ),
                    label: Text(
                      l10n.copyText,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),

                const Spacer(),

                // OK / Dismiss Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onPrimaryAction != null) {
                      onPrimaryAction!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBackup
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHigh,
                    foregroundColor: isBackup
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 10.h,
                    ),
                  ),
                  child: Text(
                    l10n.ok,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(
        file,
        height: 140.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return const SizedBox.shrink();
  }
}
