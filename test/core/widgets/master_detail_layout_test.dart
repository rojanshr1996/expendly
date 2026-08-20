import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/widgets/master_detail_layout.dart';

void main() {
  group('MasterDetailLayout', () {
    testWidgets('renders both master and detail widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MasterDetailLayout(
              master: Text('Master Content'),
              detail: Text('Detail Content'),
            ),
          ),
        ),
      );

      expect(find.text('Master Content'), findsOneWidget);
      expect(find.text('Detail Content'), findsOneWidget);
    });

    testWidgets('verifies flex values and gutter width without divider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MasterDetailLayout(
              master: Text('Master Content'),
              detail: Text('Detail Content'),
              masterFlex: 2,
              detailFlex: 3,
              gutterWidth: 20.0,
              showDivider: false,
            ),
          ),
        ),
      );

      final masterExpanded = tester.widget<Expanded>(find.ancestor(
        of: find.text('Master Content'),
        matching: find.byType(Expanded),
      ));
      expect(masterExpanded.flex, 2);

      final detailExpanded = tester.widget<Expanded>(find.ancestor(
        of: find.text('Detail Content'),
        matching: find.byType(Expanded),
      ));
      expect(detailExpanded.flex, 3);

      expect(find.byType(VerticalDivider), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('showDivider adds a divider when true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MasterDetailLayout(
              master: Text('Master Content'),
              detail: Text('Detail Content'),
              gutterWidth: 16.0,
              showDivider: true,
            ),
          ),
        ),
      );

      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });
}
