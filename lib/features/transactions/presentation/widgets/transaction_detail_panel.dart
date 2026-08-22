import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionDetailPanel extends StatelessWidget {
  final TransactionItem? transaction;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSplit;

  const TransactionDetailPanel({
    super.key,
    this.transaction,
    this.isPrivacyModeNotifier,
    this.onEdit,
    this.onDelete,
    this.onSplit,
  });

  Color _parseColor(String hex, Color fallback) {
    if (hex.isEmpty) return fallback;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'directions_bus':
        return Icons.directions_bus_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;

    if (transaction == null) {
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
                  Icons.receipt_long_rounded,
                  size: 56.0,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'No Transaction Selected',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Choose a transaction from the list on the left to view details and actions.',
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

    final t = transaction!;
    final catColor = _parseColor(t.categoryColorHex, colorScheme.primary);
    final iconData = t.type == TransactionType.transfer
        ? Icons.swap_horiz_rounded
        : _getIconData(t.categoryIcon);

    Color typeColor;
    String typeLabel;
    switch (t.type) {
      case TransactionType.income:
        typeColor = customColors.semanticGreen;
        typeLabel = 'INCOME';
        break;
      case TransactionType.expense:
        typeColor = customColors.semanticRed;
        typeLabel = 'EXPENSE';
        break;
      case TransactionType.transfer:
        typeColor = customColors.semanticBlue;
        typeLabel = 'TRANSFER';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Card
          GlassContainer(
            padding: const EdgeInsets.all(24.0),
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            child: Column(
              children: [
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: catColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: catColor,
                    size: 30.0,
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  t.type == TransactionType.transfer
                      ? 'Transfer'
                      : t.categoryName,
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
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: typeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11.0,
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ValueListenableBuilder<bool>(
                  valueListenable:
                      isPrivacyModeNotifier ?? ValueNotifier<bool>(false),
                  builder: (context, isPrivacyMode, child) {
                    return CompactAmountText(
                      amount: t.amount,
                      isPrivacyMode: isPrivacyMode,
                      showSign: true,
                      type: t.type,
                      isIncome: t.isIncome,
                      currencySymbol: t.currencyCode,
                      style: context.customTypography.amountDisplay.copyWith(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: t.isIncome
                            ? customColors.semanticGreen
                            : colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // Metadata Card
          GlassContainer(
            padding: const EdgeInsets.all(20.0),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailTile(
                  context,
                  icon: Icons.calendar_today_rounded,
                  title: 'Date & Time',
                  value:
                      DateFormat('MMM dd, yyyy • hh:mm a').format(t.timestamp),
                ),
                Divider(color: customColors.glassStroke, height: 24.0),
                _buildDetailTile(
                  context,
                  icon: Icons.category_rounded,
                  title: 'Category',
                  value: t.categoryName,
                ),
                Divider(color: customColors.glassStroke, height: 24.0),
                _buildDetailTile(
                  context,
                  icon: Icons.payment_rounded,
                  title: 'Payment Method',
                  value: t.paymentMethod?.name.toUpperCase() ?? 'CASH',
                ),
                if (t.note != null && t.note!.isNotEmpty) ...[
                  Divider(color: customColors.glassStroke, height: 24.0),
                  _buildDetailTile(
                    context,
                    icon: Icons.notes_rounded,
                    title: 'Note',
                    value: t.note!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: customColors.semanticRed,
                  side: BorderSide(
                    color: customColors.semanticRed.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),

          if (t.isExpense && onSplit != null) ...[
            const SizedBox(height: 12.0),
            OutlinedButton.icon(
              onPressed: onSplit,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              icon: const Icon(Icons.call_split_rounded, size: 18),
              label: const Text('Split Expense'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colorScheme = context.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 20.0),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
