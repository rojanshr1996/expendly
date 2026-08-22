import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/compact_amount_text.dart';
import '../../domain/entities/transaction_item.dart';

class TransactionMasterList extends StatefulWidget {
  final List<TransactionItem> transactions;
  final TransactionItem? selectedTransaction;
  final ValueChanged<TransactionItem> onTransactionSelected;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final ValueNotifier<DateTime> selectedMonthNotifier;
  final ValueNotifier<String> viewModeNotifier;
  final VoidCallback? onAddTransaction;

  const TransactionMasterList({
    super.key,
    required this.transactions,
    this.selectedTransaction,
    required this.onTransactionSelected,
    this.isPrivacyModeNotifier,
    required this.selectedMonthNotifier,
    required this.viewModeNotifier,
    this.onAddTransaction,
  });

  @override
  State<TransactionMasterList> createState() => _TransactionMasterListState();
}

class _TransactionMasterListState extends State<TransactionMasterList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Income, Expense

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<TransactionItem> _getFilteredTransactions() {
    return widget.transactions.where((tx) {
      // Type filter
      if (_selectedFilter == 'Income' && !tx.isIncome) return false;
      if (_selectedFilter == 'Expense' && !tx.isExpense) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final titleMatch = tx.categoryName.toLowerCase().contains(_searchQuery);
        final noteMatch =
            tx.note?.toLowerCase().contains(_searchQuery) ?? false;
        if (!titleMatch && !noteMatch) return false;
      }

      return true;
    }).toList();
  }

  Map<String, List<TransactionItem>> _groupTransactions(
      List<TransactionItem> items) {
    final Map<String, List<TransactionItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(
          item.timestamp.year, item.timestamp.month, item.timestamp.day);
      String key;
      if (itemDate == today) {
        key = 'TODAY';
      } else if (itemDate == yesterday) {
        key = 'YESTERDAY';
      } else {
        key = DateFormat('MMMM d, yyyy').format(item.timestamp).toUpperCase();
      }

      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final filtered = _getFilteredTransactions();
    final grouped = _groupTransactions(filtered);

    return Column(
      children: [
        // 1. Pinned Search & Filter Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.customColors.glassStroke,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.customColors.glassStroke,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8.0),
                    _buildFilterChip('Income'),
                    const SizedBox(width: 8.0),
                    _buildFilterChip('Expense'),
                    const SizedBox(width: 12.0),
                    if (widget.onAddTransaction != null)
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        onPressed: widget.onAddTransaction,
                        tooltip: 'Add Transaction',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 2. Scrollable List of Grouped Transactions
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No transactions found',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, groupIndex) {
                    final header = grouped.keys.elementAt(groupIndex);
                    final items = grouped[header]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            header,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        ...items.map(
                            (item) => _buildTransactionTile(context, item)),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : context.customColors.glassStroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionItem item) {
    final isSelected = widget.selectedTransaction?.id == item.id;
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final catColor = _parseColor(item.categoryColorHex, colorScheme.primary);
    final iconData = item.type == TransactionType.transfer
        ? Icons.swap_horiz_rounded
        : _getIconData(item.categoryIcon);

    final amountColor = item.isIncome
        ? customColors.semanticGreen
        : item.type == TransactionType.transfer
            ? customColors.semanticBlue
            : customColors.semanticRed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 3.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          onTap: () => widget.onTransactionSelected(item),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              iconData,
              color: catColor,
              size: 20,
            ),
          ),
          title: Text(
            item.type == TransactionType.transfer
                ? 'Transfer'
                : item.categoryName,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: item.note != null && item.note!.isNotEmpty
              ? Text(
                  item.note!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  DateFormat('hh:mm a').format(item.timestamp),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          trailing: ValueListenableBuilder<bool>(
            valueListenable:
                widget.isPrivacyModeNotifier ?? ValueNotifier<bool>(false),
            builder: (context, isPrivacyMode, _) {
              return CompactAmountText(
                amount: item.amount,
                isPrivacyMode: isPrivacyMode,
                showSign: true,
                type: item.type,
                isIncome: item.isIncome,
                currencySymbol: item.currencyCode,
                style: context.customTypography.labelMediumMono.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
