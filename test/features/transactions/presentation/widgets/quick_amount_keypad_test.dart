import 'package:expendly/features/transactions/presentation/widgets/quick_amount_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickAmountKeypad String Logic Tests', () {
    test('appendKey properly handles digits, decimals, and limits', () {
      expect(QuickAmountKeypad.appendKey('', '5'), equals('5'));
      expect(QuickAmountKeypad.appendKey('0', '5'), equals('5'));
      expect(QuickAmountKeypad.appendKey('5', '0'), equals('50'));
      expect(QuickAmountKeypad.appendKey('', '.'), equals('0.'));
      expect(QuickAmountKeypad.appendKey('5', '.'), equals('5.'));
      expect(QuickAmountKeypad.appendKey('5.', '.'), equals('5.'));
      expect(QuickAmountKeypad.appendKey('5.2', '5'), equals('5.25'));
      // Prevent 3rd decimal
      expect(QuickAmountKeypad.appendKey('5.25', '9'), equals('5.25'));
      // Limit 9 digits
      expect(QuickAmountKeypad.appendKey('123456789', '1'), equals('123456789'));
    });

    test('removeLastKey properly removes characters', () {
      expect(QuickAmountKeypad.removeLastKey(''), equals(''));
      expect(QuickAmountKeypad.removeLastKey('5'), equals(''));
      expect(QuickAmountKeypad.removeLastKey('50'), equals('5'));
      expect(QuickAmountKeypad.removeLastKey('50.5'), equals('50.'));
    });
  });

  group('QuickAmountKeypad Widget Tests', () {
    Widget buildTestWidget({
      required ValueChanged<String> onKeyPress,
      required VoidCallback onDeletePress,
      VoidCallback? onSubmitPress,
      String? submitLabel,
      bool isSubmitEnabled = true,
      Widget? customActionRow,
    }) {
      return MaterialApp(
        home: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => Scaffold(
            body: Center(
              child: QuickAmountKeypad(
                onKeyPress: onKeyPress,
                onDeletePress: onDeletePress,
                onSubmitPress: onSubmitPress,
                submitLabel: submitLabel,
                isSubmitEnabled: isSubmitEnabled,
                customActionRow: customActionRow,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Tapping digit buttons fires onKeyPress callback',
        (tester) async {
      String pressedKey = '';
      await tester.pumpWidget(
        buildTestWidget(
          onKeyPress: (k) => pressedKey = k,
          onDeletePress: () {},
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(pressedKey, equals('5'));

      await tester.tap(find.text('9'));
      await tester.pumpAndSettle();
      expect(pressedKey, equals('9'));

      await tester.tap(find.text('.'));
      await tester.pumpAndSettle();
      expect(pressedKey, equals('.'));
    });

    testWidgets('Tapping backspace button fires onDeletePress callback',
        (tester) async {
      bool deleted = false;
      await tester.pumpWidget(
        buildTestWidget(
          onKeyPress: (_) {},
          onDeletePress: () => deleted = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets('Submit button renders and responds when enabled',
        (tester) async {
      bool submitted = false;
      await tester.pumpWidget(
        buildTestWidget(
          onKeyPress: (_) {},
          onDeletePress: () {},
          onSubmitPress: () => submitted = true,
          submitLabel: 'Save Expense',
          isSubmitEnabled: true,
        ),
      );

      expect(find.text('Save Expense'), findsOneWidget);
      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();
      expect(submitted, isTrue);
    });

    testWidgets('Submit button is disabled when isSubmitEnabled is false',
        (tester) async {
      bool submitted = false;
      await tester.pumpWidget(
        buildTestWidget(
          onKeyPress: (_) {},
          onDeletePress: () {},
          onSubmitPress: () => submitted = true,
          submitLabel: 'Save Expense',
          isSubmitEnabled: false,
        ),
      );

      await tester.tap(find.text('Save Expense'));
      await tester.pumpAndSettle();
      expect(submitted, isFalse);
    });

    testWidgets('Renders customActionRow when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onKeyPress: (_) {},
          onDeletePress: () {},
          customActionRow: const Text('Custom Actions Here'),
        ),
      );

      expect(find.text('Custom Actions Here'), findsOneWidget);
    });
  });
}
