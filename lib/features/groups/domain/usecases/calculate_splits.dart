enum SplitMode {
  equal,
  exact,
  percentage,
}

class SplitResult {
  final int participantId;
  final double amount;
  final double percentage;

  const SplitResult({
    required this.participantId,
    required this.amount,
    required this.percentage,
  });
}

class SplitCalculationResult {
  final List<SplitResult> splits;
  final double totalAllocated;
  final double remainingAmount;
  final double totalPercentageAllocated;
  final bool isValid;
  final String? errorMessage;

  const SplitCalculationResult({
    required this.splits,
    required this.totalAllocated,
    required this.remainingAmount,
    required this.totalPercentageAllocated,
    required this.isValid,
    this.errorMessage,
  });
}

class CalculateSplits {
  /// Comprehensive multi-mode calculation method returning structured validation details and split amounts
  SplitCalculationResult calculateDetailed({
    required double totalAmount,
    required List<int> selectedParticipantIds,
    SplitMode mode = SplitMode.equal,
    Map<int, double> customAmounts = const {},
    Map<int, double> customPercentages = const {},
  }) {
    if (selectedParticipantIds.isEmpty) {
      return const SplitCalculationResult(
        splits: [],
        totalAllocated: 0,
        remainingAmount: 0,
        totalPercentageAllocated: 0,
        isValid: false,
        errorMessage: 'Select at least one participant',
      );
    }

    if (totalAmount <= 0) {
      final zeroSplits = selectedParticipantIds
          .map((id) => SplitResult(
                participantId: id,
                amount: 0,
                percentage: mode == SplitMode.percentage
                    ? (customPercentages[id] ?? 0)
                    : (100.0 / selectedParticipantIds.length),
              ))
          .toList();
      return SplitCalculationResult(
        splits: zeroSplits,
        totalAllocated: 0,
        remainingAmount: 0,
        totalPercentageAllocated: mode == SplitMode.percentage
            ? customPercentages.values.fold(0.0, (a, b) => a + b)
            : 100.0,
        isValid: true,
      );
    }

    switch (mode) {
      case SplitMode.equal:
        int totalCents = (totalAmount * 100).round();
        int count = selectedParticipantIds.length;
        int baseCents = totalCents ~/ count;
        int remainder = totalCents % count;
        double equalPct = 100.0 / count;

        List<SplitResult> splits = [];
        for (int i = 0; i < count; i++) {
          int cents = baseCents + (i < remainder ? 1 : 0);
          splits.add(SplitResult(
            participantId: selectedParticipantIds[i],
            amount: cents / 100.0,
            percentage: equalPct,
          ));
        }

        return SplitCalculationResult(
          splits: splits,
          totalAllocated: totalAmount,
          remainingAmount: 0,
          totalPercentageAllocated: 100.0,
          isValid: true,
        );

      case SplitMode.exact:
        double totalAllocated = 0.0;
        List<SplitResult> splits = [];

        for (var id in selectedParticipantIds) {
          double amt = customAmounts[id] ?? 0.0;
          totalAllocated += amt;
          double pct = totalAmount > 0 ? (amt / totalAmount) * 100 : 0.0;
          splits.add(SplitResult(
            participantId: id,
            amount: (amt * 100).round() / 100.0,
            percentage: pct,
          ));
        }

        double remainingAmount =
            ((totalAmount - totalAllocated) * 100).round() / 100.0;
        bool isValid = remainingAmount.abs() < 0.01 && totalAllocated > 0;

        String? error;
        if (remainingAmount > 0.005) {
          error = '${remainingAmount.toStringAsFixed(2)} remaining';
        } else if (remainingAmount < -0.005) {
          error = '${(-remainingAmount).toStringAsFixed(2)} over total';
        }

        return SplitCalculationResult(
          splits: splits,
          totalAllocated: (totalAllocated * 100).round() / 100.0,
          remainingAmount: remainingAmount,
          totalPercentageAllocated:
              totalAmount > 0 ? (totalAllocated / totalAmount) * 100 : 0,
          isValid: isValid,
          errorMessage: error,
        );

      case SplitMode.percentage:
        double sumCustom = 0;
        int remainingCount = 0;

        for (var id in selectedParticipantIds) {
          if (customPercentages.containsKey(id)) {
            sumCustom += customPercentages[id]!;
          } else {
            remainingCount++;
          }
        }

        double remainingPercentage = 100.0 - sumCustom;
        if (remainingPercentage < 0) remainingPercentage = 0;
        double defaultPercentage =
            remainingCount > 0 ? remainingPercentage / remainingCount : 0;

        int totalCents = (totalAmount * 100).round();
        int allocatedCents = 0;
        Map<int, int> centsPerPerson = {};

        for (var id in selectedParticipantIds) {
          double pct = customPercentages.containsKey(id)
              ? customPercentages[id]!
              : defaultPercentage;
          int cents = (totalCents * pct / 100).floor();
          centsPerPerson[id] = cents;
          allocatedCents += cents;
        }

        int remainder = totalCents - allocatedCents;
        List<SplitResult> splits = [];

        for (var id in selectedParticipantIds) {
          int cents = centsPerPerson[id]!;
          if (remainder > 0) {
            cents += 1;
            remainder -= 1;
          }
          double pct = customPercentages.containsKey(id)
              ? customPercentages[id]!
              : defaultPercentage;
          splits.add(SplitResult(
            participantId: id,
            amount: cents / 100.0,
            percentage: pct,
          ));
        }

        double totalPct = customPercentages.values.fold(0.0, (a, b) => a + b);
        if (remainingCount > 0 && remainingPercentage > 0) {
          totalPct += remainingPercentage;
        }

        double diffPct = 100.0 - totalPct;
        bool isValid = diffPct.abs() < 0.01;

        String? error;
        if (diffPct > 0.01) {
          error = '${diffPct.toStringAsFixed(1)}% remaining';
        } else if (diffPct < -0.01) {
          error = '${(-diffPct).toStringAsFixed(1)}% over 100%';
        }

        return SplitCalculationResult(
          splits: splits,
          totalAllocated: totalAmount,
          remainingAmount: 0,
          totalPercentageAllocated: totalPct,
          isValid: isValid,
          errorMessage: error,
        );
    }
  }

  /// Backward compatible wrapper returning List<SplitResult>
  List<SplitResult> calculate({
    required double totalAmount,
    required List<int> selectedParticipantIds,
    Map<int, double> customPercentages = const {},
  }) {
    final mode =
        customPercentages.isNotEmpty ? SplitMode.percentage : SplitMode.equal;
    return calculateDetailed(
      totalAmount: totalAmount,
      selectedParticipantIds: selectedParticipantIds,
      mode: mode,
      customPercentages: customPercentages,
    ).splits;
  }
}
