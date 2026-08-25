import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';

class DashboardTabletHeader extends StatelessWidget {
  final ValueNotifier<bool> isPrivacyModeNotifier;
  final VoidCallback onNewEntryPressed;
  final VoidCallback onRefreshPressed;
  final VoidCallback? onDetailedEntryPressed;
  final VoidCallback? onQuickAddPressed;

  const DashboardTabletHeader({
    super.key,
    required this.isPrivacyModeNotifier,
    required this.onNewEntryPressed,
    required this.onRefreshPressed,
    this.onDetailedEntryPressed,
    this.onQuickAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Financial Overview',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Welcome back, here is your summary.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12.0),

          // Right side
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isPrivacyModeNotifier,
                builder: (context, isPrivacyMode, child) {
                  return IconButton(
                    icon: Icon(
                      isPrivacyMode ? Icons.visibility_off : Icons.visibility,
                      color: context.colorScheme.onSurface,
                    ),
                    onPressed: () {
                      isPrivacyModeNotifier.value = !isPrivacyMode;
                    },
                    tooltip: 'Toggle Privacy Mode',
                  );
                },
              ),
              const SizedBox(width: 4.0),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: context.colorScheme.onSurface,
                ),
                onPressed: onRefreshPressed,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8.0),
              AppButton(
                text: 'Quick add',
                icon: const Icon(Icons.bolt_rounded, size: 20),
                variant: AppButtonVariant.primary,
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                height: 44,
                width: null,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                borderRadius: BorderRadius.circular(12.0),
                onPressed: onQuickAddPressed ?? onNewEntryPressed,
              ),
              const SizedBox(width: 8.0),
              if (onDetailedEntryPressed != null) ...[
                AppButton(
                  text: 'Detailed',
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  variant: AppButtonVariant.outlined,
                  height: 44,
                  width: null,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  borderRadius: BorderRadius.circular(12.0),
                  onPressed: onDetailedEntryPressed,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
