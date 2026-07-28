import 'package:intl/intl.dart';

/// Extension methods for formatting currency and large amounts.
/// When an amount is >= 100,000, it formats using compact notation (K, M, B).
/// Otherwise, it returns standard comma-separated representation.
extension AmountFormattingExtension on num {
  /// Returns compact string representation for large amounts (>= 10,000).
  /// Examples:
  ///   10000 -> "10K"
  ///   100000 -> "100K"
  ///   1500000 -> "1.5M"
  ///   2300000000 -> "2.3B"
  ///   9500 -> "9,500.00"
  String toCompactAmount() {
    final absVal = abs();
    if (absVal >= 1000000000) {
      final val = absVal / 1000000000;
      final formatted = val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1);
      return '${formatted}B';
    } else if (absVal >= 1000000) {
      final val = absVal / 1000000;
      final formatted = val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1);
      return '${formatted}M';
    } else if (absVal >= 10000) {
      final val = absVal / 1000;
      final formatted = val % 1 == 0 ? val.toStringAsFixed(0) : val.toStringAsFixed(1);
      return '${formatted}K';
    } else {
      return toFullFormattedAmount();
    }
  }

  /// Full formatted representation with comma separators and 2 decimal places.
  /// Example: 150000 -> "150,000.00"
  String toFullFormattedAmount() {
    final absVal = abs();
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(absVal);
  }

  /// Format with currency symbol, optional privacy mode, and sign.
  String formatCurrency(
    String symbol, {
    bool isPrivacyMode = false,
    bool compact = true,
    bool showSign = false,
    bool? isIncome,
  }) {
    if (isPrivacyMode) return '$symbol •••••';

    final valueString = compact ? toCompactAmount() : toFullFormattedAmount();

    String sign = '';
    if (showSign && isIncome != null) {
      sign = isIncome ? '+' : '-';
    } else if (this < 0) {
      sign = '-';
    }

    return '$sign$symbol$valueString';
  }
}
