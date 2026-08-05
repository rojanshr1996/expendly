import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:expendly/features/onboarding/presentation/widgets/onboarding_slide_card.dart';
import 'package:expendly/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    AppConfig.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Expendly Dev',
      ),
    );
  });

  Widget wrapWithMaterial(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: ThemeData(useMaterial3: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Onboarding Reusable Widgets Tests', () {
    testWidgets('OnboardingHeader renders step title, progress label, and skip button', (tester) async {
      bool skipped = false;

      await tester.pumpWidget(
        wrapWithMaterial(
          OnboardingHeader(
            progress: 0.25,
            stepLabel: 'Setup 01/04',
            titleLabel: 'Step: Welcome',
            onSkip: () => skipped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Setup 01/04'), findsOneWidget);
      expect(find.text('Step: Welcome'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      expect(skipped, isTrue);
    });

    testWidgets('OnboardingSlideCard renders icon, badge tag, title and description', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const OnboardingSlideCard(
            icon: Icons.shield_outlined,
            iconColor: Colors.teal,
            title: '100% Offline Vault',
            description: 'Local hardware encryption with zero cloud data tracking.',
            badgeTag: 'OFFLINE VAULT',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE VAULT'), findsOneWidget);
      expect(find.text('100% Offline Vault'), findsOneWidget);
      expect(find.text('Local hardware encryption with zero cloud data tracking.'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });
  });
}
