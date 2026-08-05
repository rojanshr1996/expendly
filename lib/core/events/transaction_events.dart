import 'package:flutter/foundation.dart';

/// App-wide event bus notifier for transaction changes (add, delete, update).
/// Allows Cubits across different features (Dashboard, Activity, Analytics, Budgets)
/// to instantly react and refresh state in real time without manual user refreshes.
class TransactionEvents {
  static final ValueNotifier<int> transactionUpdated = ValueNotifier<int>(0);

  static void notifyUpdated() {
    transactionUpdated.value++;
  }
}
