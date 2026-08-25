import 'package:equatable/equatable.dart';

import '../../../../core/database/enums/database_enums.dart';

/// Entity holding resolved Smart Defaults for Quick Add and Rapid Entry.
class QuickEntryDefaults extends Equatable {
  final int? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColorHex;
  final PaymentMethod paymentMethod;
  final DateTime date;
  final String currencyCode;
  final String currencySymbol;

  const QuickEntryDefaults({
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColorHex,
    required this.paymentMethod,
    required this.date,
    required this.currencyCode,
    required this.currencySymbol,
  });

  QuickEntryDefaults copyWith({
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColorHex,
    PaymentMethod? paymentMethod,
    DateTime? date,
    String? currencyCode,
    String? currencySymbol,
  }) {
    return QuickEntryDefaults(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        categoryIcon,
        categoryColorHex,
        paymentMethod,
        date,
        currencyCode,
        currencySymbol,
      ];
}
