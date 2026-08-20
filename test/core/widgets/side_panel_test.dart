import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/widgets/side_panel.dart';
import 'package:expendly/core/widgets/glass_container.dart';

void main() {
  group('SidePanel', () {
    testWidgets('renders child with specified width and padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SidePanel(
              width: 300.0,
              padding: EdgeInsets.all(10.0),
              child: Text('Panel Content'),
            ),
          ),
        ),
      );

      expect(find.text('Panel Content'), findsOneWidget);
      
      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(GlassContainer),
        matching: find.byType(SizedBox),
      ).first);
      
      expect(sizedBox.width, 300.0);

      final paddingWidget = tester.widget<Padding>(find.ancestor(
        of: find.text('Panel Content'),
        matching: find.byType(Padding),
      ).first);
      
      expect(paddingWidget.padding, const EdgeInsets.all(10.0));
    });

    testWidgets('checks default width is 280.0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SidePanel(
              child: Text('Default Panel'),
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.ancestor(
        of: find.byType(GlassContainer),
        matching: find.byType(SizedBox),
      ).first);
      
      expect(sizedBox.width, 280.0);
    });
  });
}
