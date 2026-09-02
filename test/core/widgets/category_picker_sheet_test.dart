import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/category_picker_sheet.dart';
import 'package:expendly/features/transactions/domain/entities/category_item.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapForTest(Widget child, {Size size = const Size(390, 844)}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (context, _) => MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );

    if (!getIt.isRegistered<SecureStorageService>()) {
      getIt.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
      );
    }
    if (!getIt.isRegistered<PreferenceService>()) {
      getIt.registerLazySingleton<PreferenceService>(
        () => PreferenceService(getIt<SecureStorageService>()),
      );
    }
  });

  group('CategoryPickerSheet Widget Tests', () {
    const categories = [
      CategoryItem(
        id: 1,
        name: 'Events & Celebrations',
        icon: 'celebration',
        colorHex: '#E11D48',
        type: TransactionType.expense,
      ),
      CategoryItem(
        id: 2,
        name: 'Concerts & Live Shows',
        icon: 'music_note',
        colorHex: '#8B5CF6',
        type: TransactionType.expense,
      ),
      CategoryItem(
        id: 3,
        name: 'Fitness & Gym',
        icon: 'fitness_center',
        colorHex: '#06B6D4',
        type: TransactionType.expense,
      ),
      CategoryItem(
        id: 4,
        name: 'Coffee & Cafes',
        icon: 'coffee',
        colorHex: '#D97706',
        type: TransactionType.expense,
      ),
      CategoryItem(
        id: 5,
        name: 'Beauty & Grooming',
        icon: 'spa',
        colorHex: '#F472B6',
        type: TransactionType.expense,
      ),
    ];

    testWidgets('renders all category items with their unique and befitting icons', (tester) async {
      await tester.pumpWidget(
        _wrapForTest(
          CategoryPickerSheet(
            categories: categories,
            selectedCategory: categories[0],
            initialType: TransactionType.expense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all category names are rendered
      expect(find.text('Events & Celebrations'), findsOneWidget);
      expect(find.text('Concerts & Live Shows'), findsOneWidget);
      expect(find.text('Fitness & Gym'), findsOneWidget);
      expect(find.text('Coffee & Cafes'), findsOneWidget);
      expect(find.text('Beauty & Grooming'), findsOneWidget);

      // Verify unique and befitting icons are rendered for each
      expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center_rounded), findsOneWidget);
      expect(find.byIcon(Icons.coffee_rounded), findsOneWidget);
      expect(find.byIcon(Icons.spa_rounded), findsOneWidget);

      // Verify selection checkmark is shown for selected item
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('filters category grid when searching in search bar', (tester) async {
      await tester.pumpWidget(
        _wrapForTest(
          CategoryPickerSheet(
            categories: categories,
            selectedCategory: categories[0],
            initialType: TransactionType.expense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search text 'Coffee'
      await tester.enterText(find.byType(TextField), 'Coffee');
      await tester.pumpAndSettle();

      expect(find.text('Coffee & Cafes'), findsOneWidget);
      expect(find.text('Events & Celebrations'), findsNothing);
      expect(find.text('Concerts & Live Shows'), findsNothing);
    });

    testWidgets('deduplicates alias and identical categories automatically', (tester) async {
      const listWithDuplicates = [
        CategoryItem(
          id: 10,
          name: 'Entertainment',
          icon: 'movie',
          colorHex: '#FFD1AA',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 11,
          name: 'Entertainment & Movies',
          icon: 'movie',
          colorHex: '#FFD1AA',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 12,
          name: 'Health & Wellness',
          icon: 'medical_services',
          colorHex: '#34D399',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 13,
          name: 'Health & Medical',
          icon: 'medical_services',
          colorHex: '#34D399',
          type: TransactionType.expense,
        ),
      ];

      await tester.pumpWidget(
        _wrapForTest(
          const CategoryPickerSheet(
            categories: listWithDuplicates,
            selectedCategory: null,
            initialType: TransactionType.expense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should only render 1 instance of Entertainment and 1 of Health & Wellness
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Entertainment & Movies'), findsNothing);
      expect(find.text('Health & Wellness'), findsOneWidget);
      expect(find.text('Health & Medical'), findsNothing);
    });

    testWidgets('places "Other" / "Other Expense" options at the very last position', (tester) async {
      const listWithOther = [
        CategoryItem(
          id: 99,
          name: 'Other Expense',
          icon: 'more_horiz',
          colorHex: '#94A3B8',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 1,
          name: 'Food & Dining',
          icon: 'restaurant',
          colorHex: '#FB7185',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 2,
          name: 'Coffee & Cafes',
          icon: 'coffee',
          colorHex: '#D97706',
          type: TransactionType.expense,
        ),
      ];

      await tester.pumpWidget(
        _wrapForTest(
          const CategoryPickerSheet(
            categories: listWithOther,
            selectedCategory: null,
            initialType: TransactionType.expense,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find all Text widgets inside the GridView
      final texts = tester
          .widgetList<Text>(find.descendant(
            of: find.byType(GridView),
            matching: find.byType(Text),
          ))
          .map((t) => t.data)
          .where((data) => data != null)
          .toList();

      expect(texts, ['Food & Dining', 'Coffee & Cafes', 'Other Expense']);
      expect(texts.last, equals('Other Expense'));
    });

    testWidgets('renders Overall Monthly Limit option when allowOverallLimitOption is true', (tester) async {
      await tester.pumpWidget(
        _wrapForTest(
          const CategoryPickerSheet(
            categories: categories,
            selectedCategory: null,
            initialType: TransactionType.expense,
            allowOverallLimitOption: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.all_inclusive_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
