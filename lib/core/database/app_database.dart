import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:injectable/injectable.dart';

import 'enums/database_enums.dart';
import 'tables/attachments.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/recurring_transactions.dart';
import 'tables/tags.dart';
import 'tables/transactions.dart';

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
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
      },
    );
  }

  Future<void> _seedDefaultCategories() async {
    final existing = await select(categories).get();
    if (existing.isEmpty) {
      await batch((b) {
        b.insertAll(categories, [
          // Expense Categories
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
            name: 'Housing & Bills',
            icon: 'home',
            color: '#62FAE3',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(3),
          ),
          CategoriesCompanion.insert(
            name: 'Utilities',
            icon: 'receipt_long',
            color: '#38BDF8',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(4),
          ),
          CategoriesCompanion.insert(
            name: 'Transportation',
            icon: 'directions_bus',
            color: '#C0C1FF',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(5),
          ),
          CategoriesCompanion.insert(
            name: 'Entertainment',
            icon: 'movie',
            color: '#FFD1AA',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(6),
          ),
          CategoriesCompanion.insert(
            name: 'Health & Wellness',
            icon: 'medical_services',
            color: '#34D399',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(7),
          ),
          CategoriesCompanion.insert(
            name: 'Shopping & Apparel',
            icon: 'shopping_bag',
            color: '#F472B6',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(8),
          ),
          CategoriesCompanion.insert(
            name: 'Personal Care',
            icon: 'content_cut',
            color: '#A78BFA',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(9),
          ),
          CategoriesCompanion.insert(
            name: 'Education',
            icon: 'school',
            color: '#FBBF24',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(10),
          ),
          CategoriesCompanion.insert(
            name: 'Travel & Vacation',
            icon: 'flight',
            color: '#818CF8',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(11),
          ),
          CategoriesCompanion.insert(
            name: 'Subscriptions',
            icon: 'subscriptions',
            color: '#EC4899',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(12),
          ),
          CategoriesCompanion.insert(
            name: 'Gifts & Donations',
            icon: 'card_giftcard',
            color: '#F43F5E',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(13),
          ),
          CategoriesCompanion.insert(
            name: 'Family & Childcare',
            icon: 'child_care',
            color: '#FB923C',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(14),
          ),
          CategoriesCompanion.insert(
            name: 'Pets',
            icon: 'pets',
            color: '#A3E635',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(15),
          ),
          CategoriesCompanion.insert(
            name: 'Debt & Loans',
            icon: 'credit_card',
            color: '#E11D48',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(16),
          ),
          CategoriesCompanion.insert(
            name: 'Other Expense',
            icon: 'more_horiz',
            color: '#94A3B8',
            type: TransactionType.expense,
            isDefault: const Value(true),
            sortOrder: const Value(17),
          ),

          // Income Categories
          CategoriesCompanion.insert(
            name: 'Salary',
            icon: 'payments',
            color: '#34D399',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(18),
          ),
          CategoriesCompanion.insert(
            name: 'Freelance Payout',
            icon: 'work',
            color: '#57F1DB',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(19),
          ),
          CategoriesCompanion.insert(
            name: 'Investments & Dividends',
            icon: 'trending_up',
            color: '#C0C1FF',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(20),
          ),
          CategoriesCompanion.insert(
            name: 'Business Revenue',
            icon: 'storefront',
            color: '#38BDF8',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(21),
          ),
          CategoriesCompanion.insert(
            name: 'Rental Income',
            icon: 'real_estate_agent',
            color: '#FBBF24',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(22),
          ),
          CategoriesCompanion.insert(
            name: 'Gifts & Cashbacks',
            icon: 'redeem',
            color: '#F472B6',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(23),
          ),
          CategoriesCompanion.insert(
            name: 'Refunds & Reimbursements',
            icon: 'currency_exchange',
            color: '#A78BFA',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(24),
          ),
          CategoriesCompanion.insert(
            name: 'Other Income',
            icon: 'more_horiz',
            color: '#94A3B8',
            type: TransactionType.income,
            isDefault: const Value(true),
            sortOrder: const Value(25),
          ),
        ]);
      });
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'expendly.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
