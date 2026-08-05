import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/config/app_config.dart';
import 'package:expendly/core/widgets/app_text_field.dart';

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
        home: Scaffold(body: child),
      ),
    );
  }

  group('AppTextField Component Tests', () {
    testWidgets('renders hintText, labelText, and handles text changes', (tester) async {
      final controller = TextEditingController();
      String input = '';

      await tester.pumpWidget(
        wrapWithMaterial(
          AppTextField(
            controller: controller,
            labelText: 'Username',
            hintText: 'Enter your username...',
            onChanged: (val) => input = val,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Enter your username...'), findsOneWidget);

      await tester.enterText(find.byType(AppTextField), 'JohnDoe');
      expect(input, equals('JohnDoe'));
      expect(controller.text, equals('JohnDoe'));
    });

    testWidgets('renders prefixIcon and suffixIcon correctly', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppTextField(
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.clear),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('renders errorText when validation fails', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const AppTextField(
            labelText: 'Email',
            errorText: 'Invalid email address',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid email address'), findsOneWidget);
    });
  });
}
