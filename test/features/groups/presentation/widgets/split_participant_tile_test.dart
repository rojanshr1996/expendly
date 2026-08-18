import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/groups/domain/entities/expense_split.dart';
import 'package:expendly/features/groups/presentation/widgets/split_participant_tile.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _createTestWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
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
  testWidgets('SplitParticipantTile renders name and handles toggle',
      (WidgetTester tester) async {
    bool? toggledValue;

    const split = ExpenseSplit(
      id: 1,
      expenseId: 10,
      participantId: 2,
      participantName: 'Bob',
      isSelected: true,
      splitAmount: 50.0,
    );

    await tester.pumpWidget(
      _createTestWidget(
        SplitParticipantTile(
          split: split,
          isEqually: true,
          onToggle: (val) {
            toggledValue = val;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);

    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);

    await tester.tap(checkbox);
    expect(toggledValue, isFalse);
  });
}
