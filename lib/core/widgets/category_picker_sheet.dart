import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/transactions/domain/entities/category_item.dart';
import '../database/enums/database_enums.dart';
import '../extensions/context_extensions.dart';
import '../responsive/breakpoints.dart';
import '../theme/font_weights.dart';
import '../utils/category_icon_helper.dart';
import 'adaptive_sheet.dart';

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
    return AdaptiveSheet.show<CategoryItem?>(
      context: context,
      isScrollControlled: true,
      maxDialogWidth: 600.0,
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

  IconData _parseIcon(String name, [String? categoryName]) {
    return CategoryIconHelper.getIcon(name, categoryName);
  }

  static String _normalizeCategoryName(String name) {
    final lower = name.toLowerCase().trim();
    if (lower == 'entertainment & movies' || lower == 'entertainment') {
      return 'entertainment';
    }
    if (lower == 'health & medical' || lower == 'health & wellness') {
      return 'health & wellness';
    }
    if (lower == 'bills & utilities' || lower == 'utilities') {
      return 'utilities';
    }
    if (lower == 'housing & bills' || lower == 'housing') {
      return 'housing & bills';
    }
    if (lower == 'shopping & apparel' || lower == 'shopping') {
      return 'shopping & apparel';
    }
    return lower;
  }

  static bool _isOtherCategory(String name) {
    final lower = name.toLowerCase().trim();
    return lower == 'other' ||
        lower == 'other expense' ||
        lower == 'other income' ||
        lower == 'others' ||
        lower == 'misc' ||
        lower == 'miscellaneous' ||
        lower.startsWith('other ');
  }

  List<CategoryItem> _getDisplayCategories(String query) {
    // 1. Deduplicate by ID and normalized category key
    final seenKeys = <String>{};
    final seenIds = <int>{};
    final deduplicated = <CategoryItem>[];

    for (final cat in widget.categories) {
      if (seenIds.contains(cat.id)) continue;
      final normKey = '${cat.type.name}_${_normalizeCategoryName(cat.name)}';
      if (seenKeys.contains(normKey)) continue;

      seenIds.add(cat.id);
      seenKeys.add(normKey);
      deduplicated.add(cat);
    }

    // 2. Filter by search query
    final cleanQuery = query.trim().toLowerCase();
    final matched = deduplicated.where((cat) {
      if (cleanQuery.isEmpty) return true;
      return cat.name.toLowerCase().contains(cleanQuery);
    }).toList();

    // 3. Separate standard categories and "other" categories to guarantee "other" is last
    final regular = <CategoryItem>[];
    final other = <CategoryItem>[];

    for (final cat in matched) {
      if (_isOtherCategory(cat.name)) {
        other.add(cat);
      } else {
        regular.add(cat);
      }
    }

    return [...regular, ...other];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final customTypography = context.customTypography;
    final customColors = context.customColors;
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isTablet = Breakpoints.isTablet(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: isTablet ? 560.0 : MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color:
              isLight ? colorScheme.surface : colorScheme.surfaceContainerHigh,
          borderRadius: isTablet
              ? BorderRadius.circular(24.0)
              : BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(
            color: isLight
                ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                : customColors.glassStroke.withValues(alpha: 0.45),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 20.w,
          vertical: isTablet ? 20.0 : 16.h,
        ),
        child: Column(
          children: [
            // Sheet Handle & Drag Bar (mobile only)
            if (!isTablet) ...[
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isLight
                        ? colorScheme.outline.withValues(alpha: 0.4)
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

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

            // Search Bar Component
            ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, _) {
                final br = BorderRadius.circular(16.r);
                return Container(
                  decoration: BoxDecoration(
                    color: isLight
                        ? colorScheme.surfaceContainerLow
                        : colorScheme.surfaceContainerHigh,
                    borderRadius: br,
                    border: Border.all(
                      color: isLight
                          ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                          : customColors.glassStroke.withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _searchQueryNotifier.value = val,
                    style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchCategoryHint,
                      hintStyle:
                          (textTheme.bodyMedium ?? const TextStyle()).copyWith(
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20.sp,
                      ),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18.sp,
                                color: colorScheme.outline,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchQueryNotifier.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // Category Grid
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _searchQueryNotifier,
                builder: (context, query, _) {
                  final displayCategories = _getDisplayCategories(query);

                  if (displayCategories.isEmpty) {
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

                  final isTablet = Breakpoints.isTablet(context);

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 4 : 3,
                      crossAxisSpacing: isTablet ? 12.0 : 10.w,
                      mainAxisSpacing: isTablet ? 12.0 : 10.h,
                      childAspectRatio: isTablet ? 1.15 : 1.05,
                    ),
                    itemCount: displayCategories.length +
                        (widget.allowOverallLimitOption ? 1 : 0),
                    itemBuilder: (context, index) {
                      // "Overall" option always appears first when enabled
                      if (widget.allowOverallLimitOption && index == 0) {
                        final isOverallSelected =
                            widget.selectedCategory == null;
                        return _buildGridItem(
                          context: context,
                          isSelected: isOverallSelected,
                          icon: Icons.all_inclusive_rounded,
                          iconColor: colorScheme.primary,
                          label: l10n.overallMonthlyLimit,
                          onTap: () => Navigator.pop(context, null),
                        );
                      }

                      final cat = displayCategories[
                          index - (widget.allowOverallLimitOption ? 1 : 0)];
                      final isSelected = widget.selectedCategory?.id == cat.id;
                      final color = _parseColor(context, cat.colorHex);
                      final icon = _parseIcon(cat.icon, cat.name);

                      return _buildGridItem(
                        context: context,
                        isSelected: isSelected,
                        icon: icon,
                        iconColor: color,
                        label: cat.name,
                        onTap: () => Navigator.pop(context, cat),
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

  Widget _buildGridItem({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = context.colorScheme;
    final customColors = context.customColors;
    final textTheme = context.textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isDark = !isLight;
    final isTablet = Breakpoints.isTablet(context);
    final br = BorderRadius.circular(isTablet ? 16.0 : 16.r);
    final selectedBg = colorScheme.primary;
    final selectedFg = isLight ? Colors.white : colorScheme.onPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: br,
          color: isSelected
              ? selectedBg
              : (isLight
                  ? colorScheme.surfaceContainerLowest
                  : colorScheme.surfaceContainerLow),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : (isLight
                    ? colorScheme.outlineVariant.withValues(alpha: 0.50)
                    : customColors.glassStroke.withValues(alpha: 0.45)),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary
                        .withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: isTablet ? 8.0 : 8.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 6.0 : 6.w,
            vertical: isTablet ? 6.0 : 8.h,
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
                    width: isTablet ? 44.0 : 44.w,
                    height: isTablet ? 44.0 : 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : iconColor.withValues(alpha: isLight ? 0.14 : 0.20),
                      border: isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1.0,
                            )
                          : Border.all(
                              color: iconColor.withValues(
                                  alpha: isLight ? 0.30 : 0.40),
                              width: 1.0,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: isSelected ? selectedFg : iconColor,
                      size: isTablet ? 22.0 : 22.sp,
                    ),
                  ),
                  SizedBox(height: isTablet ? 4.0 : 6.h),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (textTheme.bodySmall ?? const TextStyle()).copyWith(
                        fontSize: isTablet ? 11.0 : 11.sp,
                        height: 1.2,
                        fontWeight:
                            isSelected ? FontWeights.bold : FontWeights.medium,
                        color: isSelected ? selectedFg : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 2.0 : 2.r),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: isTablet ? 11.0 : 11.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
