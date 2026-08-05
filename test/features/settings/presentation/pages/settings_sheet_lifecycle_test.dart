import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for the settings export/import bottom sheets.
///
/// The sheets used to create their `TextEditingController`s in the page and
/// dispose them from `showModalBottomSheet(...).whenComplete(...)`. That future
/// resolves as soon as `Navigator.pop` is called, but the sheet subtree stays
/// mounted and keeps rebuilding for the whole exit animation — in the app the
/// closing keyboard changes `MediaQuery.viewInsets` and rebuilds it. That
/// rebuild then hit a freed controller and threw "A TextEditingController was
/// used after being disposed."
///
/// The fix moved the controllers into `StatefulWidget`s owned by the sheet, so
/// `dispose()` runs only once the route has actually left the tree. This test
/// pins that lifetime contract: rebuilding all through the dismissal must stay
/// clean, and the controller must still be disposed afterwards.
///
/// `rebuildTick` stands in for whatever rebuilds the sheet mid-dismissal, so the
/// race is deterministic rather than dependent on keyboard-inset timing.
void main() {
  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets(
    'sheet-owned controller survives dismissal and the exit animation',
    (tester) async {
      final rebuildTick = ValueNotifier<int>(0);
      addTearDown(rebuildTick.dispose);

      late BuildContext pageContext;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) {
              pageContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      showModalBottomSheet<void>(
        context: pageContext,
        isScrollControlled: true,
        builder: (ctx) => _SheetOwningController(rebuildTick: rebuildTick),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      final state = tester.state<_SheetOwningControllerState>(
        find.byType(_SheetOwningController),
      );
      expect(state.isControllerAlive, isTrue);

      // Pop, then rebuild on every frame of the exit animation. Disposing from
      // the route future instead threw on the first of these.
      Navigator.of(tester.element(find.byType(TextField))).pop();
      for (var i = 0; i < 6; i++) {
        rebuildTick.value++;
        await tester.pump(const Duration(milliseconds: 40));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsNothing);
      // dispose() still ran — just not until the route left the tree.
      expect(state.isControllerAlive, isFalse);
    },
  );
}

/// Stand-in for `_ExportPassphraseSheet` / `_ImportSheet`: owns the controller
/// and rebuilds when [rebuildTick] changes.
class _SheetOwningController extends StatefulWidget {
  const _SheetOwningController({required this.rebuildTick});

  final ValueNotifier<int> rebuildTick;

  @override
  State<_SheetOwningController> createState() => _SheetOwningControllerState();
}

class _SheetOwningControllerState extends State<_SheetOwningController> {
  final TextEditingController _controller = TextEditingController();
  bool isControllerAlive = true;

  @override
  void dispose() {
    isControllerAlive = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.rebuildTick,
      builder: (context, _, __) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: TextField(controller: _controller),
      ),
    );
  }
}
