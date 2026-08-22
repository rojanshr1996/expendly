import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/di/injection.dart';
import 'package:expendly/core/responsive/breakpoints.dart';
import 'package:expendly/core/services/preference_service.dart';
import 'package:expendly/core/services/secure_storage_service.dart';
import 'package:expendly/core/theme/app_theme.dart';
import 'package:expendly/core/widgets/adaptive_sheet.dart';
import 'package:expendly/core/widgets/status_components.dart';
import 'package:expendly/features/dashboard/presentation/widgets/quick_action_fab.dart';
import 'package:expendly/l10n/app_localizations.dart';

Widget _wrapTestApp(Widget child, {Size size = const Size(1024, 768)}) {
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

  group('Tablet Phase 4 Adaptive & E2E Tests', () {
    testWidgets(
        'AdaptiveSheet renders Dialog on tablet (1024x768) and ModalBottomSheet on phone (375x812)',
        (tester) async {
      // 1. Test Tablet layout (1024 x 768)
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrapTestApp(
          Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () {
                  AdaptiveSheet.show(
                    context: ctx,
                    maxDialogWidth: 440,
                    builder: (_) => const Text('Adaptive Dialog Content'),
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
          size: const Size(1024, 768),
        ),
      );
      await tester.pumpAndSettle();

      // Tap open
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // On tablet, it renders inside Dialog
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Adaptive Dialog Content'), findsOneWidget);

      // Dismiss dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // 2. Test Phone layout (375 x 812)
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        _wrapTestApp(
          Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () {
                  AdaptiveSheet.show(
                    context: ctx,
                    maxDialogWidth: 440,
                    builder: (_) => const Text('Adaptive Phone Sheet'),
                  );
                },
                child: const Text('Open Sheet Phone'),
              );
            },
          ),
          size: const Size(375, 812),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet Phone'));
      await tester.pumpAndSettle();

      // On phone, it does NOT render inside Dialog (it uses ModalBottomSheet)
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Adaptive Phone Sheet'), findsOneWidget);
    });

    testWidgets(
        'StatusComponents.showConfirmationBottomSheet presents adaptively',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      bool? userResponse;

      await tester.pumpWidget(
        _wrapTestApp(
          Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () async {
                  userResponse =
                      await StatusComponents.showConfirmationBottomSheet(
                    ctx,
                    title: 'Delete Budget',
                    message: 'Are you sure you want to delete this budget?',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                },
                child: const Text('Trigger Confirm'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Confirm'));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Delete Budget'), findsOneWidget);
      expect(
          find.text('Are you sure you want to delete this budget?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Confirm
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(userResponse, true);
    });

    testWidgets('QuickActionFab speed dial opens adaptively on tablet',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final GlobalKey<QuickActionFabState> fabKey =
          GlobalKey<QuickActionFabState>();

      await tester.pumpWidget(
        _wrapTestApp(
          QuickActionFab(
            key: fabKey,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger speed dial
      fabKey.currentState?.openSpeedDial(fabKey.currentContext!);
      await tester.pumpAndSettle();

      // Verify modal options appear
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('Breakpoints utility correctly identifies device tiers',
        (tester) async {
      expect(Breakpoints.compactMax, 600.0);
      expect(Breakpoints.expandedMin, 840.0);

      // Compact width
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(_wrapTestApp(Builder(builder: (ctx) {
        expect(Breakpoints.of(ctx), DeviceType.compact);
        expect(Breakpoints.isTablet(ctx), isFalse);
        expect(Breakpoints.isExpanded(ctx), isFalse);
        return const SizedBox.shrink();
      })));

      // Medium tablet width (iPad Mini)
      tester.view.physicalSize = const Size(744, 1133);
      await tester.pumpWidget(_wrapTestApp(Builder(builder: (ctx) {
        expect(Breakpoints.of(ctx), DeviceType.medium);
        expect(Breakpoints.isTablet(ctx), isTrue);
        expect(Breakpoints.isExpanded(ctx), isFalse);
        return const SizedBox.shrink();
      })));

      // Expanded tablet width (iPad Pro)
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(_wrapTestApp(Builder(builder: (ctx) {
        expect(Breakpoints.of(ctx), DeviceType.expanded);
        expect(Breakpoints.isTablet(ctx), isTrue);
        expect(Breakpoints.isExpanded(ctx), isTrue);
        return const SizedBox.shrink();
      })));
    });
  });
}
