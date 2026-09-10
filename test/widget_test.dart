import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flounder/home.dart';
import 'package:flounder/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Hold-to-pause functionality test when active', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const Flounder());

    // Pump frames to let async initialization complete
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    // Verify FlounderHome is present
    expect(find.byType(FlounderHome), findsOneWidget);

    // Start timer by tapping FlounderActionButton
    final actionButton = find.byType(FlounderActionButton);
    expect(actionButton, findsOneWidget);
    await tester.tap(actionButton);
    await tester.pump();

    // Advance 2 seconds
    await tester.pump(const Duration(seconds: 2));

    // Find primary clock
    final primaryClockFinder = find.byType(FlounderTimer).first;
    expect(primaryClockFinder, findsOneWidget);

    final center = tester.getCenter(primaryClockFinder);

    // Press down (hold) on the main clock
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump();

    // Get clock text right after press
    final initialText = tester.widget<Text>(find.descendant(of: primaryClockFinder, matching: find.byType(Text))).data;

    // Advance time while holding down
    await tester.pump(const Duration(seconds: 3));

    // Time display when held should stay frozen
    final frozenText = tester.widget<Text>(find.descendant(of: primaryClockFinder, matching: find.byType(Text))).data;
    expect(frozenText, equals(initialText));

    // Release gesture
    await gesture.up();
    await tester.pump();

    // Advance 2 seconds after release
    await tester.pump(const Duration(seconds: 2));
    final resumedText = tester.widget<Text>(find.descendant(of: primaryClockFinder, matching: find.byType(Text))).data;
    expect(resumedText, isNot(equals(frozenText)));
  });

  testWidgets('Hold-to-pause ignored when timer is idle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const Flounder());

    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    final primaryClockFinder = find.byType(FlounderTimer).first;
    final center = tester.getCenter(primaryClockFinder);

    // Press down when idle
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    // Timer mode should remain Idle
    expect(find.text('Idle'), findsOneWidget);
  });
}
