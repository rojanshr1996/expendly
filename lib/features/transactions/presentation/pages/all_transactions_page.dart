import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction_item.dart';
import '../cubit/transaction_cubit.dart';
import '../cubit/transaction_state.dart';

class AllTransactionsPage extends StatelessWidget {
  final ValueNotifier<bool>? isPrivacyModeNotifier;

  const AllTransactionsPage({super.key, this.isPrivacyModeNotifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;

    return BlocProvider(
      create: (_) {
        try {
          return getIt<TransactionCubit>()..loadTransactions();
        } catch (_) {
          final db = getIt<AppDatabase>();
          final ds = TransactionLocalDataSourceImpl(db);
          final repo = TransactionRepositoryImpl(ds);
          return TransactionCubit(repo)..loadTransactions();
        }
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: true,
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_rounded,
                          color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                context.l10n.activity,
                style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Column(
              children: [
                // Search Bar Header using custom AppTextField component
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: AppTextField(
                    hintText: context.l10n.searchCategoryHint,
                    prefixIcon:
                        Icon(Icons.search_rounded, color: colorScheme.outline),
                    fillColor: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (val) {
                      context.read<TransactionCubit>().filterSearch(val);
                    },
                  ),
                ),

                // Transactions List
                Expanded(
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        );
                      }

                      if (state is TransactionLoaded) {
                        final items = state.filteredTransactions;
                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.noTransactionsFound,
                                  style:
                                      customTypography.bodyLargeBold.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.noTransactionsDesc,
                                  style: customTypography.bodyMedium.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Group transactions by Date
                        final Map<String, List<TransactionItem>> grouped = {};
                        for (final item in items) {
                          final dateKey = _formatDateKey(item.timestamp);
                          grouped.putIfAbsent(dateKey, () => []).add(item);
                        }

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => context
                              .read<TransactionCubit>()
                              .loadTransactions(),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: grouped.keys.length,
                            itemBuilder: (context, index) {
                              final dateKey = grouped.keys.elementAt(index);
                              final dateItems = grouped[dateKey]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: Text(
                                      dateKey.toUpperCase(),
                                      style: customTypography.labelMediumMono
                                          .copyWith(
                                        color: AppColors.outline,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),

                                  // Date Items
                                  ...dateItems.map(
                                    (tx) => _TransactionListTile(
                                      transaction: tx,
                                      isPrivacyModeNotifier:
                                          isPrivacyModeNotifier,
                                      onDelete: () {
                                        context
                                            .read<TransactionCubit>()
                                            .deleteTransaction(tx.id);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final check = DateTime(dt.year, dt.month, dt.day);

    if (check == today) return 'Today';
    if (check == yesterday) return 'Yesterday';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _TransactionListTile extends StatelessWidget {
  final TransactionItem transaction;
  final ValueNotifier<bool>? isPrivacyModeNotifier;
  final VoidCallback onDelete;

  const _TransactionListTile({
    required this.transaction,
    this.isPrivacyModeNotifier,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final customTypography = context.customTypography;
    final catColor = _parseColor(transaction.categoryColorHex);

    return Dismissible(
      key: Key('tx_${transaction.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.semanticRed.withOpacity(0.8),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassStroke),
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(transaction.categoryIcon),
                color: catColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Title & Note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: customTypography.bodyLargeBold.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (transaction.note?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        transaction.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: customTypography.bodyMedium.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Amount Display
            ValueListenableBuilder<bool>(
              valueListenable: isPrivacyModeNotifier ?? ValueNotifier(false),
              builder: (context, isPrivacy, _) {
                final isIncome = transaction.isIncome;
                final sign = isIncome ? '+' : '-';
                final color =
                    isIncome ? AppColors.semanticGreen : AppColors.semanticRed;
                final amountText = isPrivacy
                    ? '•••••'
                    : '$sign\$${transaction.amount.toStringAsFixed(2)}';

                return Text(
                  amountText,
                  style: customTypography.headlineMediumMonoBold.copyWith(
                    color: color,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
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
}
