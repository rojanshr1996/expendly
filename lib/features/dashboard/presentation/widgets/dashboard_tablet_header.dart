import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class DashboardTabletHeader extends StatelessWidget {
  final ValueNotifier<bool> isPrivacyModeNotifier;
  final VoidCallback onNewEntryPressed;
  final VoidCallback onRefreshPressed;

  const DashboardTabletHeader({
    super.key,
    required this.isPrivacyModeNotifier,
    required this.onNewEntryPressed,
    required this.onRefreshPressed,
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
              ElevatedButton.icon(
                onPressed: onNewEntryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'New Entry',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
