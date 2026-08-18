import '../entities/event_participant.dart';
import '../entities/group_expense.dart';
import '../entities/settlement.dart';

class CalculateSettlements {
  /// Given a list of expenses with their splits, calculate the direct pairwise settlements between participants.
  List<Settlement> calculate({
    required List<GroupExpense> expenses,
    required List<EventParticipant> participants,
  }) {
    if (expenses.isEmpty || participants.isEmpty) return [];

    // debtMatrix[debtorId][creditorId] = amount debtor owes creditor
    final Map<int, Map<int, double>> debtMatrix = {};
    // reasonsMatrix[debtorId][creditorId] = set of expense titles
    final Map<int, Map<int, Set<String>>> reasonsMatrix = {};

    for (var p1 in participants) {
      debtMatrix[p1.id] = {};
      reasonsMatrix[p1.id] = {};
      for (var p2 in participants) {
        debtMatrix[p1.id]![p2.id] = 0.0;
        reasonsMatrix[p1.id]![p2.id] = <String>{};
      }
    }

    for (var expense in expenses) {
      final payerId = expense.paidByParticipantId;
      for (var split in expense.splits) {
        final splitId = split.participantId;
        if (splitId != payerId && split.splitAmount > 0) {
          if (debtMatrix.containsKey(splitId) &&
              debtMatrix[splitId]!.containsKey(payerId)) {
            debtMatrix[splitId]![payerId] =
                (debtMatrix[splitId]![payerId] ?? 0.0) + split.splitAmount;
            if (expense.title.isNotEmpty) {
              reasonsMatrix[splitId]![payerId]!.add(expense.title);
            }
          }
        }
      }
    }

    final List<Settlement> settlements = [];

    // Compute pairwise net debts between each unique pair of participants
    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        final p1 = participants[i];
        final p2 = participants[j];

        final owes1to2 = debtMatrix[p1.id]?[p2.id] ?? 0.0;
        final owes2to1 = debtMatrix[p2.id]?[p1.id] ?? 0.0;

        final combinedReasons = <String>{
          ...?reasonsMatrix[p1.id]?[p2.id],
          ...?reasonsMatrix[p2.id]?[p1.id],
        }.toList();

        final net = owes1to2 - owes2to1;

        if (net > 0.01) {
          settlements.add(
            Settlement(
              fromParticipant: p1,
              toParticipant: p2,
              amount: (net * 100).round() / 100,
              reasons: combinedReasons,
            ),
          );
        } else if (net < -0.01) {
          settlements.add(
            Settlement(
              fromParticipant: p2,
              toParticipant: p1,
              amount: ((-net) * 100).round() / 100,
              reasons: combinedReasons,
            ),
          );
        }
      }
    }

    return settlements;
  }
}
