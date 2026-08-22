import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expendly/core/responsive/breakpoints.dart';
import 'package:expendly/core/responsive/responsive_extensions.dart';

void main() {
  Widget buildTestWidget(double width, WidgetBuilder builder) {
    return MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Builder(builder: builder),
    );
  }

  group('Breakpoints tests', () {
    testWidgets('width = 375 (compact, isTablet=false, isExpanded=false)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;

      await tester.pumpWidget(buildTestWidget(375, (context) {
        type = Breakpoints.of(context);
        isTablet = Breakpoints.isTablet(context);
        isExpanded = Breakpoints.isExpanded(context);
        return const SizedBox();
      }));

      expect(type, DeviceType.compact);
      expect(isTablet, isFalse);
      expect(isExpanded, isFalse);
    });

    testWidgets('width = 600 (medium, isTablet=true, isExpanded=false)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;

      await tester.pumpWidget(buildTestWidget(600, (context) {
        type = Breakpoints.of(context);
        isTablet = Breakpoints.isTablet(context);
        isExpanded = Breakpoints.isExpanded(context);
        return const SizedBox();
      }));

      expect(type, DeviceType.medium);
      expect(isTablet, isTrue);
      expect(isExpanded, isFalse);
    });

    testWidgets('width = 750 (medium, isTablet=true, isExpanded=false)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;

      await tester.pumpWidget(buildTestWidget(750, (context) {
        type = Breakpoints.of(context);
        isTablet = Breakpoints.isTablet(context);
        isExpanded = Breakpoints.isExpanded(context);
        return const SizedBox();
      }));

      expect(type, DeviceType.medium);
      expect(isTablet, isTrue);
      expect(isExpanded, isFalse);
    });

    testWidgets('width = 840 (expanded, isTablet=true, isExpanded=true)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;

      await tester.pumpWidget(buildTestWidget(840, (context) {
        type = Breakpoints.of(context);
        isTablet = Breakpoints.isTablet(context);
        isExpanded = Breakpoints.isExpanded(context);
        return const SizedBox();
      }));

      expect(type, DeviceType.expanded);
      expect(isTablet, isTrue);
      expect(isExpanded, isTrue);
    });

    testWidgets('width = 1024 (expanded, isTablet=true, isExpanded=true)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;

      await tester.pumpWidget(buildTestWidget(1024, (context) {
        type = Breakpoints.of(context);
        isTablet = Breakpoints.isTablet(context);
        isExpanded = Breakpoints.isExpanded(context);
        return const SizedBox();
      }));

      expect(type, DeviceType.expanded);
      expect(isTablet, isTrue);
      expect(isExpanded, isTrue);
    });
  });

  group('ResponsiveExtension tests', () {
    testWidgets('width = 375 (compact)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;
      bool? isCompact;

      await tester.pumpWidget(buildTestWidget(375, (context) {
        type = context.deviceType;
        isTablet = context.isTablet;
        isExpanded = context.isExpanded;
        isCompact = context.isCompact;
        return const SizedBox();
      }));

      expect(type, DeviceType.compact);
      expect(isTablet, isFalse);
      expect(isExpanded, isFalse);
      expect(isCompact, isTrue);
    });

    testWidgets('width = 750 (medium)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;
      bool? isCompact;

      await tester.pumpWidget(buildTestWidget(750, (context) {
        type = context.deviceType;
        isTablet = context.isTablet;
        isExpanded = context.isExpanded;
        isCompact = context.isCompact;
        return const SizedBox();
      }));

      expect(type, DeviceType.medium);
      expect(isTablet, isTrue);
      expect(isExpanded, isFalse);
      expect(isCompact, isFalse);
    });

    testWidgets('width = 1024 (expanded)', (tester) async {
      DeviceType? type;
      bool? isTablet;
      bool? isExpanded;
      bool? isCompact;

      await tester.pumpWidget(buildTestWidget(1024, (context) {
        type = context.deviceType;
        isTablet = context.isTablet;
        isExpanded = context.isExpanded;
        isCompact = context.isCompact;
        return const SizedBox();
      }));

      expect(type, DeviceType.expanded);
      expect(isTablet, isTrue);
      expect(isExpanded, isTrue);
      expect(isCompact, isFalse);
    });
  });
}
