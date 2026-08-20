import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/responsive/responsive_builder.dart';

void main() {
  Widget buildTestWidget(double width, Widget child) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      ),
    );
  }

  group('ResponsiveBuilder tests', () {
    testWidgets('Renders compact builder on compact screen (< 600px)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        375,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
          medium: (context) => const Text('Medium'),
          expanded: (context) => const Text('Expanded'),
        ),
      ));

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Medium'), findsNothing);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('Renders medium builder on medium screen (600 - 839px)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        700,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
          medium: (context) => const Text('Medium'),
          expanded: (context) => const Text('Expanded'),
        ),
      ));

      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Compact'), findsNothing);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('Falls back to compact builder on medium screen if medium is not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        700,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
          expanded: (context) => const Text('Expanded'),
        ),
      ));

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Expanded'), findsNothing);
    });

    testWidgets('Renders expanded builder on expanded screen (>= 840px)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        1024,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
          medium: (context) => const Text('Medium'),
          expanded: (context) => const Text('Expanded'),
        ),
      ));

      expect(find.text('Expanded'), findsOneWidget);
      expect(find.text('Compact'), findsNothing);
      expect(find.text('Medium'), findsNothing);
    });

    testWidgets('Falls back to medium builder on expanded screen if expanded is not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        1024,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
          medium: (context) => const Text('Medium'),
        ),
      ));

      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Compact'), findsNothing);
    });

    testWidgets('Falls back to compact builder on expanded screen if expanded and medium are not provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        1024,
        ResponsiveBuilder(
          compact: (context) => const Text('Compact'),
        ),
      ));

      expect(find.text('Compact'), findsOneWidget);
    });
  });
}
