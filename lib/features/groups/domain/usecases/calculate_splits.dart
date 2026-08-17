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
        double sumCustom = 0.0;
        int remainingCount = 0;
        List<int> unassignedIds = [];

        for (var id in selectedParticipantIds) {
          if (customAmounts.containsKey(id) && customAmounts[id] != null) {
            sumCustom += customAmounts[id]!;
          } else {
            remainingCount++;
            unassignedIds.add(id);
          }
        }

        sumCustom = (sumCustom * 100).round() / 100.0;
        double remainingAmount =
            ((totalAmount - sumCustom) * 100).round() / 100.0;

        List<SplitResult> splits = [];

        if (remainingCount > 0) {
          if (remainingAmount >= 0) {
            int remainingCents = (remainingAmount * 100).round();
            int baseCents = remainingCents ~/ remainingCount;
            int remainderCents = remainingCents % remainingCount;

            int unassignedIndex = 0;
            for (var id in selectedParticipantIds) {
              if (customAmounts.containsKey(id) && customAmounts[id] != null) {
                double amt = customAmounts[id]!;
                double pct = totalAmount > 0 ? (amt / totalAmount) * 100 : 0.0;
                splits.add(SplitResult(
                  participantId: id,
                  amount: (amt * 100).round() / 100.0,
                  percentage: pct,
                ));
              } else {
                int cents =
                    baseCents + (unassignedIndex < remainderCents ? 1 : 0);
                unassignedIndex++;
                double amt = cents / 100.0;
                double pct = totalAmount > 0 ? (amt / totalAmount) * 100 : 0.0;
                splits.add(SplitResult(
                  participantId: id,
                  amount: amt,
                  percentage: pct,
                ));
              }
            }

            return SplitCalculationResult(
              splits: splits,
              totalAllocated: totalAmount,
              remainingAmount: 0.0,
              totalPercentageAllocated: 100.0,
              isValid: totalAmount > 0,
            );
          } else {
            // Custom amount exceeds total amount
            for (var id in selectedParticipantIds) {
              if (customAmounts.containsKey(id) && customAmounts[id] != null) {
                double amt = customAmounts[id]!;
                double pct = totalAmount > 0 ? (amt / totalAmount) * 100 : 0.0;
                splits.add(SplitResult(
                  participantId: id,
                  amount: (amt * 100).round() / 100.0,
                  percentage: pct,
                ));
              } else {
                splits.add(SplitResult(
                  participantId: id,
                  amount: 0.0,
                  percentage: 0.0,
                ));
              }
            }

            return SplitCalculationResult(
              splits: splits,
              totalAllocated: sumCustom,
              remainingAmount: remainingAmount,
              totalPercentageAllocated:
                  totalAmount > 0 ? (sumCustom / totalAmount) * 100 : 0.0,
              isValid: false,
              errorMessage:
                  '${(-remainingAmount).toStringAsFixed(2)} over total',
            );
          }
        } else {
          // All participants have explicitly set custom amounts
          for (var id in selectedParticipantIds) {
            double amt = customAmounts[id] ?? 0.0;
            double pct = totalAmount > 0 ? (amt / totalAmount) * 100 : 0.0;
            splits.add(SplitResult(
              participantId: id,
              amount: (amt * 100).round() / 100.0,
              percentage: pct,
            ));
          }

          bool isValid = remainingAmount.abs() < 0.01 && totalAmount > 0;
          String? error;
          if (remainingAmount > 0.005) {
            error = '${remainingAmount.toStringAsFixed(2)} remaining';
          } else if (remainingAmount < -0.005) {
            error = '${(-remainingAmount).toStringAsFixed(2)} over total';
          }

          return SplitCalculationResult(
            splits: splits,
            totalAllocated: sumCustom,
            remainingAmount: remainingAmount,
            totalPercentageAllocated:
                totalAmount > 0 ? (sumCustom / totalAmount) * 100 : 0.0,
            isValid: isValid,
            errorMessage: error,
          );
        }

      case SplitMode.percentage:
        double sumCustom = 0;
        int remainingCount = 0;

        for (var id in selectedParticipantIds) {
          if (customPercentages.containsKey(id) &&
              customPercentages[id] != null) {
            sumCustom += customPercentages[id]!;
          } else {
            remainingCount++;
          }
        }

        sumCustom = (sumCustom * 100).round() / 100.0;
        double remainingPercentage = 100.0 - sumCustom;
        if (remainingPercentage < 0) remainingPercentage = 0;
        double defaultPercentage =
            remainingCount > 0 ? remainingPercentage / remainingCount : 0;

        int totalCents = (totalAmount * 100).round();
        int allocatedCents = 0;
        Map<int, int> centsPerPerson = {};

        for (var id in selectedParticipantIds) {
          double pct = (customPercentages.containsKey(id) &&
                  customPercentages[id] != null)
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
          double pct = (customPercentages.containsKey(id) &&
                  customPercentages[id] != null)
              ? customPercentages[id]!
              : defaultPercentage;
          splits.add(SplitResult(
            participantId: id,
            amount: cents / 100.0,
            percentage: pct,
          ));
        }

        double totalPct = sumCustom;
        if (remainingCount > 0 && remainingPercentage > 0) {
          totalPct += remainingPercentage;
        }

        double diffPct = 100.0 - totalPct;
        bool isValid = diffPct.abs() < 0.01 && (sumCustom <= 100.01);

        String? error;
        if (sumCustom > 100.01) {
          double over = sumCustom - 100.0;
          error = '${over.toStringAsFixed(1)}% over 100%';
          isValid = false;
        } else if (remainingCount == 0 && diffPct > 0.01) {
          error = '${diffPct.toStringAsFixed(1)}% remaining';
          isValid = false;
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
