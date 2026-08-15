import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/transactions/domain/entities/category_item.dart';
import '../database/enums/database_enums.dart';
import '../extensions/context_extensions.dart';
import '../theme/font_weights.dart';
import 'app_text_field.dart';

/// Reusable modal sheet for picking a category from a responsive grid.
/// Solves category pill scrolling issues by offering search, icons, and clean grid views.
/// The [categories] list should already be pre-filtered for the correct type by the
/// parent widget; this sheet only applies search-query filtering on top.
class CategoryPickerSheet extends StatefulWidget {
  final List<CategoryItem> categories;
  final CategoryItem? selectedCategory;
  final TransactionType initialType;
  final bool allowOverallLimitOption;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.initialType = TransactionType.expense,
    this.allowOverallLimitOption = false,
  });

  static Future<CategoryItem?> show({
    required BuildContext context,
    required List<CategoryItem> categories,
    CategoryItem? selectedCategory,
    TransactionType initialType = TransactionType.expense,
    bool allowOverallLimitOption = false,
  }) {
    return showModalBottomSheet<CategoryItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryPickerSheet(
        categories: categories,
        selectedCategory: selectedCategory,
        initialType: initialType,
        allowOverallLimitOption: allowOverallLimitOption,
      ),
    );
  }

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late final TextEditingController _searchController;
  late final ValueNotifier<String> _searchQueryNotifier;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchQueryNotifier = ValueNotifier<String>('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Color _parseColor(BuildContext context, String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        final color = Color(int.parse('FF$clean', radix: 16));
        if (Theme.of(context).brightness == Brightness.light) {
          final hsl = HSLColor.fromColor(color);
          if (hsl.lightness > 0.5) {
            return hsl
                .withLightness((hsl.lightness - 0.25).clamp(0.2, 0.45))
                .toColor();
          }
        }
        return color;
      }
    } catch (_) {}
    return context.colorScheme.primary;
  }

  IconData _parseIcon(String name) {
    switch (name.toLowerCase()) {
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'movie':
      case 'entertainment':
        return Icons.movie_outlined;
      case 'local_taxi':
      case 'transport':
      case 'commute':
        return Icons.directions_car_rounded;
      case 'payments':
      case 'salary':
      case 'income':
        return Icons.payments_outlined;
      case 'work':
      case 'freelance':
        return Icons.work_outline_rounded;
      case 'fitness_center':
      case 'health':
        return Icons.fitness_center_rounded;
      case 'home':
      case 'bills':
      case 'rent':
        return Icons.home_work_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // Sheet Handle & Drag Bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha((0.4 * 255).round()),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.categoryLabel,
                  style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontWeight: FontWeights.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Search Bar Component using AppTextField
            AppTextField(
              controller: _searchController,
              hintText: l10n.searchCategoryHint,
              prefixIcon:
                  Icon(Icons.search_rounded, color: colorScheme.outline),
              fillColor: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.r),
              onChanged: (query) => _searchQueryNotifier.value = query,
            ),
            SizedBox(height: 16.h),

            // Category Grid
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, query, _) {
                  // The parent passes a pre-filtered list (expense or income
                  // categories), so we only need to apply the search query here.
                  final filtered = widget.categories.where((cat) {
                    return query.isEmpty ||
                        cat.name.toLowerCase().contains(query.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 48.sp, color: colorScheme.outline),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.noCategoriesFound,
                            style: customTypography.bodyMedium
                                .copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: filtered.length +
                        (widget.allowOverallLimitOption ? 1 : 0),
                    itemBuilder: (context, index) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;

                      // "Overall" option always appears first when enabled
                      if (widget.allowOverallLimitOption && index == 0) {
                        final isOverallSelected =
                            widget.selectedCategory == null;
                        return GestureDetector(
                          onTap: () => Navigator.pop(context, null),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              color: isOverallSelected
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: isOverallSelected
                                    ? colorScheme.primary
                                    : context.customColors.glassStroke,
                                width: isOverallSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isOverallSelected
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary.withValues(
                                            alpha: isDark ? 0.45 : 0.30),
                                        blurRadius: 10.r,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(7.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOverallSelected
                                            ? colorScheme.onPrimary
                                                .withValues(alpha: 0.22)
                                            : colorScheme.primary
                                                .withValues(alpha: 0.15),
                                      ),
                                      child: Icon(
                                        Icons.all_inclusive_rounded,
                                        color: isOverallSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.primary,
                                        size: 22.sp,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      l10n.overallMonthlyLimit,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: (textTheme.bodySmall ??
                                              const TextStyle())
                                          .copyWith(
                                        fontSize: 11.sp,
                                        height: 1.2,
                                        fontWeight: isOverallSelected
                                            ? FontWeights.bold
                                            : FontWeights.medium,
                                        color: isOverallSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isOverallSelected)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(2.r),
                                      decoration: BoxDecoration(
                                        color: colorScheme.onPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 11.sp,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      final cat = filtered[
                          index - (widget.allowOverallLimitOption ? 1 : 0)];
                      final isSelected = widget.selectedCategory?.id == cat.id;
                      final color = _parseColor(context, cat.colorHex);
                      final icon = _parseIcon(cat.icon);

                      return GestureDetector(
                        onTap: () => Navigator.pop(context, cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerLow,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : context.customColors.glassStroke,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                          alpha: isDark ? 0.45 : 0.30),
                                      blurRadius: 10.r,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(7.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                              .withValues(alpha: 0.22)
                                          : color.withValues(alpha: 0.15),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : color,
                                      size: 22.sp,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: (textTheme.bodySmall ??
                                            const TextStyle())
                                        .copyWith(
                                      fontSize: 11.sp,
                                      height: 1.2,
                                      fontWeight: isSelected
                                          ? FontWeights.bold
                                          : FontWeights.medium,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(2.r),
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 11.sp,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
