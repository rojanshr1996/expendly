import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/database/enums/database_enums.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/category_picker_sheet.dart';
import 'package:expendly/features/settings/presentation/widgets/settings_category_sidebar.dart';
import 'package:expendly/features/transactions/domain/entities/category_item.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _wrapWithScreenUtil(Widget child, {Size size = const Size(1024, 768)}) {
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

  group('Tablet Phase 3 Widgets Tests', () {
    testWidgets('SettingsCategorySidebar renders all 5 categories and selects',
        (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          StatefulBuilder(
            builder: (context, setState) {
              return SettingsCategorySidebar(
                selectedCategoryIndex: selected,
                onCategorySelected: (idx) {
                  setState(() {
                    selected = idx;
                  });
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Settings'), findsOneWidget);

      // Verify Categories exist
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byIcon(Icons.palette_rounded), findsOneWidget);
      expect(find.byIcon(Icons.backup_rounded), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);

      // Tap on Security category (index 1)
      await tester.tap(find.byIcon(Icons.lock_rounded));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('CategoryPickerSheet renders responsive grid on tablet',
        (tester) async {
      const sampleCategories = [
        CategoryItem(
          id: 1,
          name: 'Food & Dining',
          icon: 'restaurant',
          colorHex: '#FF5722',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 2,
          name: 'Shopping',
          icon: 'shopping_cart',
          colorHex: '#4CAF50',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 3,
          name: 'Transport',
          icon: 'directions_bus',
          colorHex: '#2196F3',
          type: TransactionType.expense,
        ),
        CategoryItem(
          id: 4,
          name: 'Entertainment',
          icon: 'movie',
          colorHex: '#9C27B0',
          type: TransactionType.expense,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithScreenUtil(
          CategoryPickerSheet(
            categories: sampleCategories,
            selectedCategory: sampleCategories.first,
            initialType: TransactionType.expense,
            allowOverallLimitOption: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify categories appear
      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);

      // Verify GridView exists
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
