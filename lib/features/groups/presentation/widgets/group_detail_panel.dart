import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/sharing_event.dart';

class GroupDetailPanel extends StatelessWidget {
  final SharingEvent? event;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAddExpense;
  final VoidCallback? onSettleUp;

  const GroupDetailPanel({
    super.key,
    this.event,
    this.onViewDetails,
    this.onAddExpense,
    this.onSettleUp,
  });

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return '✈️';
      case 'dinner':
        return '🍴';
      case 'home':
        return '🏠';
      case 'party':
        return '🎉';
      case 'groceries':
        return '🛒';
      case 'utilities':
        return '⚡';
      case 'entertainment':
        return '🎬';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛍️';
      case 'sports':
        return '⚽';
      case 'work':
        return '💼';
      default:
        return '📁';
    }
  }

  Color _getParticipantColor(int index) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00B4D8),
      const Color(0xFF38B000),
      const Color(0xFFFF9F1C),
      const Color(0xFFE63946),
      const Color(0xFF9B5DE5),
      const Color(0xFF00F5D4),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    if (event == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(32.0),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.diversity_3_rounded,
                  size: 56.0,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No Event Selected',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Choose a split group or event from the left list to view member shares and expenses.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ev = event!;
    final isSettled = ev.status.toLowerCase() == 'settled';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Hero Event Header
          GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getCategoryIcon(ev.category),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  ev.name,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isSettled
                        ? customColors.semanticGreen.withValues(alpha: 0.12)
                        : colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSettled
                          ? customColors.semanticGreen.withValues(alpha: 0.4)
                          : colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    isSettled ? 'SETTLED' : 'ACTIVE',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isSettled
                          ? customColors.semanticGreen
                          : colorScheme.primary,
                    ),
                  ),
                ),
                if (ev.description.isNotEmpty) ...[
                  const SizedBox(height: 12.0),
                  Text(
                    ev.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20.0),

                // Financial Breakdown Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TOTAL SPENT',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            CompactAmountText(
                              amount: ev.totalSpent,
                              style: context.customTypography.amountDisplay
                                  .copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'YOUR SHARE',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            CompactAmountText(
                              amount: ev.userShare,
                              style: context.customTypography.amountDisplay
                                  .copyWith(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // 2. Participants Section
          GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members (${ev.participants.length})',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Started ${DateFormat.yMMMd().format(ev.startDate)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                ...ev.participants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final avatarColor = _getParticipantColor(index);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16.0,
                          backgroundColor: avatarColor.withValues(alpha: 0.2),
                          child: Text(
                            p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: avatarColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            p.name,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (p.isOwner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'OWNER',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // 3. Actions
          ElevatedButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18.0),
            label: const Text('View Full Event & Expenses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
