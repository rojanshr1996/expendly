import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/enums/database_enums.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/category_picker_sheet.dart';
import '../../../transactions/domain/entities/category_item.dart';
import '../cubit/budget_cubit.dart';

class CreateNewBudgetModal extends StatefulWidget {
  final VoidCallback onSaved;

  const CreateNewBudgetModal({super.key, required this.onSaved});

  @override
  State<CreateNewBudgetModal> createState() => _CreateNewBudgetModalState();
}

class _CreateNewBudgetModalState extends State<CreateNewBudgetModal> {
  final TextEditingController _amountController = TextEditingController();
  CategoryItem? _selectedCategory;
  List<CategoryItem> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final db = getIt<AppDatabase>();
      final rows = await db.select(db.categories).get();
      if (mounted) {
        setState(() {
          _expenseCategories = rows
              .where((r) => r.type == TransactionType.expense)
              .map((r) => CategoryItem(
                    id: r.id,
                    name: r.name,
                    icon: r.icon,
                    colorHex: r.color,
                    type: r.type,
                  ))
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final customTypography = context.customTypography;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.setMonthlyBudget,
                style: customTypography.bodyLargeBold.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Amount Input using custom AppTextField component
          AppTextField(
            controller: _amountController,
            labelText: context.l10n.targetMonthlyAmount,
            hintText: 'e.g. 500.00',
            isAmount: true,
            fillColor: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),

          const SizedBox(height: 20),

          // Category Selector Button (opens CategoryPickerSheet)
          Text(
            context.l10n.categoryLabel,
            style: customTypography.labelMediumMono.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await CategoryPickerSheet.show(
                context: context,
                categories: _expenseCategories,
                selectedCategory: _selectedCategory,
                initialType: TransactionType.expense,
                allowOverallLimitOption: true,
              );
              setState(() {
                _selectedCategory = picked;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary
                              .withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _selectedCategory == null
                              ? Icons.all_inclusive_rounded
                              : Icons.category_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategory?.name ??
                            context.l10n.overallMonthlyLimit,
                        style: customTypography.bodyLargeBold.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: colorScheme.outline,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Save Button
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.enterTargetAmountError),
                    backgroundColor: colorScheme.error,
                  ),
                );
                return;
              }

              final budgetCubit = getIt<BudgetCubit>();
              await budgetCubit.setBudget(
                categoryId: _selectedCategory?.id,
                targetAmount: amount,
              );

              if (!mounted) return;
              widget.onSaved();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.l10n.saveBudget,
              style:
                  customTypography.bodyLargeBold.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
