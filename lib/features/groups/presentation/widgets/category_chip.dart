import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extensions.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _getCategoryLabel(BuildContext context, String cat) {
    switch (cat.toLowerCase()) {
      case 'trip':
        return context.l10n.trip;
      case 'dinner':
        return context.l10n.dinner;
      case 'home':
        return context.l10n.home;
      case 'party':
        return context.l10n.party;
      case 'groceries':
        return 'Groceries';
      case 'utilities':
        return 'Bills & Utilities';
      case 'entertainment':
        return 'Entertainment';
      case 'transport':
        return 'Transport';
      case 'shopping':
        return 'Shopping';
      case 'sports':
        return 'Sports & Fitness';
      case 'work':
        return 'Work & Projects';
      case 'others':
        return 'Others';
      default:
        return cat.isNotEmpty
            ? '${cat[0].toUpperCase()}${cat.substring(1)}'
            : cat;
    }
  }

  String _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
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
      case 'others':
      default:
        return '📁';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _getCategoryLabel(context, category);
    final icon = _getCategoryIcon(category);

    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : context.customColors.glassStroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 8.w),
            Text(
              label,
              style: context.customTypography.labelMediumMono.copyWith(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
