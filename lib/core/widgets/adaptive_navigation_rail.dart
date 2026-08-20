import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../extensions/context_extensions.dart';

class NavRailItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const NavRailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}

class AdaptiveNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onNewEntryPressed;
  final bool isExpanded;
  final List<NavRailItem> items;
  final List<NavRailItem> bottomItems;

  const AdaptiveNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onNewEntryPressed,
    this.isExpanded = true,
    required this.items,
    this.bottomItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final width = isExpanded ? 200.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh.withValues(alpha: 0.35),
        border: Border(
          right: BorderSide(
            color: context.customColors.glassStroke,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: SafeArea(
            right: false,
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(
                      left: isExpanded ? 10.0 : 12.0,
                      right: isExpanded ? 10.0 : 11.0,
                    ),
                    children: items
                        .map((item) => _buildNavItem(context, item))
                        .toList(),
                  ),
                ),
                if (bottomItems.isNotEmpty) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isExpanded ? 10.0 : 12.0,
                      right: isExpanded ? 10.0 : 11.0,
                    ),
                    child: Column(
                      children: bottomItems
                          .map((item) => _buildNavItem(context, item))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _buildNewEntryButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 14 : 12),
      alignment: Alignment.center,
      child: isExpanded
          ? Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Expendly',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavRailItem item) {
    final isSelected = selectedIndex == item.index;
    final colorScheme = context.colorScheme;

    final navWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onDestinationSelected(item.index);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: isExpanded
              ? Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    if (isSelected)
                      Positioned(
                        left: 0,
                        top: 10,
                        bottom: 10,
                        child: Container(
                          width: 3.5,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(3),
                              bottomRight: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: isExpanded
          ? navWidget
          : Tooltip(
              message: item.label,
              preferBelow: false,
              child: navWidget,
            ),
    );
  }

  Widget _buildNewEntryButton(BuildContext context) {
    final colorScheme = context.colorScheme;
    final buttonWidth = isExpanded ? 180.0 : 48.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: isExpanded ? 10.0 : 12.0,
          right: isExpanded ? 10.0 : 11.0,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 48,
          width: buttonWidth,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onNewEntryPressed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isExpanded
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'New Entry',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Icon(Icons.add_rounded, size: 22),
                  ),
          ),
        ),
      ),
    );
  }
}
