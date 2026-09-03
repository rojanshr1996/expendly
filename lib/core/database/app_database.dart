import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'enums/database_enums.dart';
import 'tables/attachments.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/recurring_transactions.dart';
import 'tables/tags.dart';
import 'tables/transactions.dart';
import 'tables/user_profiles.dart';
import 'tables/sharing_events.dart';
import 'tables/event_participants.dart';
import 'tables/group_expenses.dart';
import 'tables/expense_splits.dart';

part 'app_database.g.dart';

@lazySingleton
@DriftDatabase(tables: [
  Categories,
  Subcategories,
  Transactions,
  Tags,
  TransactionTags,
  Attachments,
  Budgets,
  RecurringTransactions,
  UserProfiles,
  SharingEvents,
  EventParticipants,
  GroupExpenses,
  ExpenseSplits,
])
class AppDatabase extends _$AppDatabase {
  @factoryMethod
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await _cleanupDuplicateCategories();
        await _seedDefaultCategories();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Schema v2 migration: Add columns to existing tables
          await m.addColumn(transactions, transactions.recurringTransactionId);
          await m.addColumn(budgets, budgets.year);
          await m.addColumn(budgets, budgets.month);
          await m.addColumn(budgets, budgets.currencyCode);
          await m.addColumn(
              recurringTransactions, recurringTransactions.isAutoCreate);
          await m.addColumn(
              recurringTransactions, recurringTransactions.isActive);
          await m.addColumn(
              recurringTransactions, recurringTransactions.lastProcessedDate);
          await m.addColumn(categories, categories.isDefault);
          await m.addColumn(categories, categories.sortOrder);
        }
        if (from < 3) {
          await m.addColumn(transactions, transactions.paymentMethod);
        }
        if (from < 4) {
          await m.addColumn(budgets, budgets.notifyAtThreshold);
          await m.addColumn(budgets, budgets.thresholdPercentage);
        }
        if (from < 5) {
          await m.createTable(userProfiles);
        }
        if (from < 6) {
          await m.createTable(sharingEvents);
          await m.createTable(eventParticipants);
          await m.createTable(groupExpenses);
          await m.createTable(expenseSplits);
        }
      },
    );
  }

  /// Flushes the WAL into the main database file so the file on disk is
  /// self-contained and safe to copy for backup.
  Future<void> checkpointForBackup() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
  }

  /// Runs SQLite integrity check. Returns true if the database is healthy.
  Future<bool> integrityCheck() async {
    final rows = await customSelect('PRAGMA integrity_check;').get();
    return rows.first.data.values.first == 'ok';
  }

  /// Returns the total count of transactions in the database.
  Future<int> getTransactionCount() async {
    final count = await (selectOnly(transactions)
          ..addColumns([transactions.id.count()]))
        .getSingle();
    return count.read(transactions.id.count()) ?? 0;
  }

  /// Checks whether any transactions exist in the database.
  Future<bool> hasAnyTransactions() async {
    return (await getTransactionCount()) > 0;
  }

  Future<void> _seedDefaultCategories() async {
    final existing = await select(categories).get();
    final defaultList = [
      // Expense Categories (Daily & Essentials)
      CategoriesCompanion.insert(
        name: 'Food & Dining',
        icon: 'restaurant',
        color: '#FB7185',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(1),
      ),
      CategoriesCompanion.insert(
        name: 'Grocery Shopping',
        icon: 'shopping_cart',
        color: '#FFAC5A',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(2),
      ),
      CategoriesCompanion.insert(
        name: 'Coffee & Cafes',
        icon: 'coffee',
        color: '#D97706',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(3),
      ),
      CategoriesCompanion.insert(
        name: 'Housing & Bills',
        icon: 'home',
        color: '#62FAE3',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(4),
      ),
      CategoriesCompanion.insert(
        name: 'Utilities',
        icon: 'receipt_long',
        color: '#38BDF8',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(5),
      ),
      CategoriesCompanion.insert(
        name: 'Transportation',
        icon: 'directions_bus',
        color: '#C0C1FF',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(6),
      ),

      // Expense Categories (Personal & Lifestyle)
      CategoriesCompanion.insert(
        name: 'Personal Care',
        icon: 'content_cut',
        color: '#A78BFA',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(7),
      ),
      CategoriesCompanion.insert(
        name: 'Beauty & Grooming',
        icon: 'spa',
        color: '#F472B6',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(8),
      ),
      CategoriesCompanion.insert(
        name: 'Self Care & Wellness',
        icon: 'self_improvement',
        color: '#2DD4BF',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(9),
      ),
      CategoriesCompanion.insert(
        name: 'Fitness & Gym',
        icon: 'fitness_center',
        color: '#06B6D4',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(10),
      ),
      CategoriesCompanion.insert(
        name: 'Shopping & Apparel',
        icon: 'shopping_bag',
        color: '#F43F5E',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(11),
      ),
      CategoriesCompanion.insert(
        name: 'Hobbies & Crafts',
        icon: 'palette',
        color: '#F59E0B',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(12),
      ),
      CategoriesCompanion.insert(
        name: 'Books & Media',
        icon: 'menu_book',
        color: '#14B8A6',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(13),
      ),
      CategoriesCompanion.insert(
        name: 'Electronics & Gadgets',
        icon: 'devices',
        color: '#3B82F6',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(14),
      ),
      CategoriesCompanion.insert(
        name: 'Health & Wellness',
        icon: 'medical_services',
        color: '#34D399',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(15),
      ),
      CategoriesCompanion.insert(
        name: 'Education',
        icon: 'school',
        color: '#FBBF24',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(16),
      ),
      CategoriesCompanion.insert(
        name: 'Subscriptions',
        icon: 'subscriptions',
        color: '#EC4899',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(17),
      ),

      // Expense Categories (Events & Leisure)
      CategoriesCompanion.insert(
        name: 'Events & Celebrations',
        icon: 'celebration',
        color: '#E11D48',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(18),
      ),
      CategoriesCompanion.insert(
        name: 'Concerts & Live Shows',
        icon: 'music_note',
        color: '#8B5CF6',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(19),
      ),
      CategoriesCompanion.insert(
        name: 'Weddings & Ceremonies',
        icon: 'favorite',
        color: '#DB2777',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(20),
      ),
      CategoriesCompanion.insert(
        name: 'Sports & Stadium Events',
        icon: 'sports_soccer',
        color: '#10B981',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(21),
      ),
      CategoriesCompanion.insert(
        name: 'Nightlife & Bars',
        icon: 'nightlife',
        color: '#9333EA',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(22),
      ),
      CategoriesCompanion.insert(
        name: 'Entertainment',
        icon: 'movie',
        color: '#FFD1AA',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(23),
      ),
      CategoriesCompanion.insert(
        name: 'Travel & Vacation',
        icon: 'flight',
        color: '#818CF8',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(24),
      ),

      // Expense Categories (Family & Social)
      CategoriesCompanion.insert(
        name: 'Gifts & Donations',
        icon: 'card_giftcard',
        color: '#FB7185',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(25),
      ),
      CategoriesCompanion.insert(
        name: 'Family & Childcare',
        icon: 'child_care',
        color: '#FB923C',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(26),
      ),
      CategoriesCompanion.insert(
        name: 'Pets',
        icon: 'pets',
        color: '#A3E635',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(27),
      ),
      CategoriesCompanion.insert(
        name: 'Debt & Loans',
        icon: 'credit_card',
        color: '#E11D48',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(28),
      ),
      CategoriesCompanion.insert(
        name: 'Other Expense',
        icon: 'more_horiz',
        color: '#94A3B8',
        type: TransactionType.expense,
        isDefault: const Value(true),
        sortOrder: const Value(29),
      ),

      // Income Categories
      CategoriesCompanion.insert(
        name: 'Salary',
        icon: 'payments',
        color: '#34D399',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(30),
      ),
      CategoriesCompanion.insert(
        name: 'Freelance Payout',
        icon: 'work',
        color: '#57F1DB',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(31),
      ),
      CategoriesCompanion.insert(
        name: 'Investments & Dividends',
        icon: 'trending_up',
        color: '#C0C1FF',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(32),
      ),
      CategoriesCompanion.insert(
        name: 'Business Revenue',
        icon: 'storefront',
        color: '#38BDF8',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(33),
      ),
      CategoriesCompanion.insert(
        name: 'Rental Income',
        icon: 'real_estate_agent',
        color: '#FBBF24',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(34),
      ),
      CategoriesCompanion.insert(
        name: 'Gifts & Cashbacks',
        icon: 'redeem',
        color: '#F472B6',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(35),
      ),
      CategoriesCompanion.insert(
        name: 'Refunds & Reimbursements',
        icon: 'currency_exchange',
        color: '#A78BFA',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(36),
      ),
      CategoriesCompanion.insert(
        name: 'Other Income',
        icon: 'more_horiz',
        color: '#94A3B8',
        type: TransactionType.income,
        isDefault: const Value(true),
        sortOrder: const Value(37),
      ),
    ];

    if (existing.isEmpty) {
      await batch((b) {
        b.insertAll(categories, defaultList);
      });
    } else {
      final existingNames =
          existing.map((c) => c.name.toLowerCase().trim()).toSet();
      final missing = defaultList.where((c) {
        return !existingNames.contains(c.name.value.toLowerCase().trim());
      }).toList();

      if (missing.isNotEmpty) {
        await batch((b) {
          b.insertAll(categories, missing);
        });
      }
    }
  }

  /// Cleans up any duplicate or alias category rows created across migrations
  /// to ensure consistent and unique categories in the database.
  Future<void> _cleanupDuplicateCategories() async {
    try {
      final aliasMap = {
        'entertainment & movies': 'Entertainment',
        'health & medical': 'Health & Wellness',
        'bills & utilities': 'Utilities',
      };

      for (final entry in aliasMap.entries) {
        final duplicateRows = await (select(categories)
              ..where((c) => c.name.lower().equals(entry.key)))
            .get();
        if (duplicateRows.isEmpty) continue;

        final targetRows = await (select(categories)
              ..where((c) => c.name.lower().equals(entry.value.toLowerCase())))
            .get();

        if (targetRows.isNotEmpty) {
          final targetId = targetRows.first.id;
          for (final dup in duplicateRows) {
            if (dup.id == targetId) continue;
            await (update(transactions)
                  ..where((t) => t.categoryId.equals(dup.id)))
                .write(TransactionsCompanion(categoryId: Value(targetId)));
            await (update(budgets)..where((b) => b.categoryId.equals(dup.id)))
                .write(BudgetsCompanion(categoryId: Value(targetId)));
            await (update(recurringTransactions)
                  ..where((r) => r.categoryId.equals(dup.id)))
                .write(RecurringTransactionsCompanion(
                    categoryId: Value(targetId)));
            await (delete(categories)..where((c) => c.id.equals(dup.id))).go();
          }
        } else {
          // Rename the first duplicate row to target name
          await (update(categories)
                ..where((c) => c.id.equals(duplicateRows.first.id)))
              .write(CategoriesCompanion(name: Value(entry.value)));
        }
      }

      // Merge exact duplicate names if any exist
      final allCats = await select(categories).get();
      final seen = <String, int>{};
      for (final cat in allCats) {
        final key = '${cat.type.name}_${cat.name.toLowerCase().trim()}';
        if (seen.containsKey(key)) {
          final primaryId = seen[key]!;
          await (update(transactions)
                ..where((t) => t.categoryId.equals(cat.id)))
              .write(TransactionsCompanion(categoryId: Value(primaryId)));
          await (update(budgets)..where((b) => b.categoryId.equals(cat.id)))
              .write(BudgetsCompanion(categoryId: Value(primaryId)));
          await (update(recurringTransactions)
                ..where((r) => r.categoryId.equals(cat.id)))
              .write(
                  RecurringTransactionsCompanion(categoryId: Value(primaryId)));
          await (delete(categories)..where((c) => c.id.equals(cat.id))).go();
        } else {
          seen[key] = cat.id;
        }
      }
    } catch (_) {}
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expendly.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
