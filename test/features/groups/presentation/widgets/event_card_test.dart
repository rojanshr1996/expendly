import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/features/groups/domain/entities/event_participant.dart';
import 'package:expendly/features/groups/domain/entities/sharing_event.dart';
import 'package:expendly/features/groups/presentation/widgets/event_card.dart';
import 'package:expendly/features/groups/presentation/widgets/status_badge.dart';
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

  final testEvent = SharingEvent(
    id: 1,
    name: 'Trip to Bali',
    description: 'Vacation with friends',
    startDate: DateTime(2026, 6, 1),
    category: 'trip',
    status: 'active',
    createdAt: DateTime(2026, 5, 20),
    participants: const [
      EventParticipant(id: 1, eventId: 1, name: 'Alice', isOwner: true, colorIndex: 0),
      EventParticipant(id: 2, eventId: 1, name: 'Bob', isOwner: false, colorIndex: 1),
    ],
    totalSpent: 450.0,
    userShare: 225.0,
  );

  testWidgets('EventCard displays event details, status badge, and responds to tap',
      (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      _createTestWidget(
        EventCard(
          event: testEvent,
          onTap: () {
            wasTapped = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Trip to Bali'), findsOneWidget);
    expect(find.text('2 Members'), findsOneWidget);
    expect(find.byType(StatusBadge), findsOneWidget);

    await tester.tap(find.byType(EventCard));
    expect(wasTapped, isTrue);
  });
}
