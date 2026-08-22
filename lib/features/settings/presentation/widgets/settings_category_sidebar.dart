import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

class SettingsCategorySidebar extends StatelessWidget {
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelected;

  const SettingsCategorySidebar({
    super.key,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final categories = [
      {
        'index': 0,
        'icon': Icons.person_rounded,
        'title': context.l10n.accountSection,
        'subtitle': 'Personal profile & details',
      },
      {
        'index': 1,
        'icon': Icons.lock_rounded,
        'title': context.l10n.securitySection,
        'subtitle': 'PIN code & biometrics',
      },
      {
        'index': 2,
        'icon': Icons.palette_rounded,
        'title': context.l10n.appearanceSection,
        'subtitle': 'Themes & regional settings',
      },
      {
        'index': 3,
        'icon': Icons.backup_rounded,
        'title': context.l10n.dataManagementSection,
        'subtitle': 'Export, import & backup',
      },
      {
        'index': 4,
        'icon': Icons.info_rounded,
        'title': context.l10n.supportAndLegalSection,
        'subtitle': 'Version, terms & privacy',
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settings,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Preferences & Account',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          ...categories.map((cat) {
            final index = cat['index'] as int;
            final icon = cat['icon'] as IconData;
            final title = cat['title'] as String;
            final subtitle = cat['subtitle'] as String;
            final isSelected = selectedCategoryIndex == index;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: true,
                  onTap: () => onCategorySelected(index),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
