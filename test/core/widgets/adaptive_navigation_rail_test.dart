import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/widgets/adaptive_navigation_rail.dart';

void main() {
  group('AdaptiveNavigationRail', () {
    final items = [
      const NavRailItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        index: 0,
      ),
      const NavRailItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Stats',
        index: 1,
      ),
    ];

    testWidgets('renders brand header with "Expendly" and navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onNewEntryPressed: () {},
              items: items,
              isExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Expendly'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget); // active
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget); // inactive
    });

    testWidgets('tapping navigation item triggers onDestinationSelected callback', (WidgetTester tester) async {
      int? selectedIdx;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (index) {
                selectedIdx = index;
              },
              onNewEntryPressed: () {},
              items: items,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      
      expect(selectedIdx, 1);
    });

    testWidgets('tapping "New Entry" button triggers onNewEntryPressed callback', (WidgetTester tester) async {
      bool newEntryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onNewEntryPressed: () {
                newEntryPressed = true;
              },
              items: items,
            ),
          ),
        ),
      );

      await tester.tap(find.text('New Entry'));
      await tester.pumpAndSettle();
      
      expect(newEntryPressed, isTrue);
    });

    testWidgets('tests expanded state (width 200) and collapsed state (width 72)', (WidgetTester tester) async {
      // Expanded
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onNewEntryPressed: () {},
              items: items,
              isExpanded: true,
            ),
          ),
        ),
      );

      final sizeExpanded = tester.getSize(find.byType(AdaptiveNavigationRail));
      expect(sizeExpanded.width, 200.0);
      expect(find.text('Expendly'), findsOneWidget);

      // Collapsed
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onNewEntryPressed: () {},
              items: items,
              isExpanded: false,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      final sizeCollapsed = tester.getSize(find.byType(AdaptiveNavigationRail));
      expect(sizeCollapsed.width, 72.0);
      expect(find.text('Expendly'), findsNothing);
    });

    testWidgets('collapsed rail centers icons and active background exactly in the rail', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              onNewEntryPressed: () {},
              items: items,
              isExpanded: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final railCenter = tester.getCenter(find.byType(AdaptiveNavigationRail));
      final activeIconCenter = tester.getCenter(find.byIcon(Icons.home));

      // The icon's horizontal center must align with the rail's horizontal center (36.0)
      expect(activeIconCenter.dx, equals(railCenter.dx));
    });
  });
}
