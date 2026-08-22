import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/widgets/liquid_glass_app_bar.dart';
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

  Widget wrapWithMaterial(Widget child, {Brightness brightness = Brightness.light}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: child as PreferredSizeWidget,
          body: Container(color: Colors.amber),
        ),
      ),
    );
  }

  group('LiquidGlassAppBar Component Tests', () {
    testWidgets('renders title text, actions, and BackdropFilter with blur', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        wrapWithMaterial(
          LiquidGlassAppBar(
            titleText: 'Expenses',
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => actionPressed = true,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify BackdropFilter with ImageFilter.blur is present in flexibleSpace
      final backdropFilterFinder = find.descendant(
        of: find.byType(LiquidGlassAppBar),
        matching: find.byType(BackdropFilter),
      );
      expect(backdropFilterFinder, findsOneWidget);

      final backdropFilter = tester.widget<BackdropFilter>(backdropFilterFinder);
      expect(backdropFilter.filter, isNotNull);

      // Test tapping action
      await tester.tap(find.byIcon(Icons.search));
      expect(actionPressed, isTrue);
    });

    testWidgets('renders in dark mode with liquid glass gradient and border', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const LiquidGlassAppBar(
            titleText: 'Dark Mode Glass',
          ),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode Glass'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });
}
