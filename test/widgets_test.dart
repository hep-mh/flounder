import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flounder/state.dart';
import 'package:flounder/widgets.dart';

void main() {
  testWidgets('FlounderHeader renders properly', (WidgetTester tester) async {
    final state = ApplicationState();
    state.mode = ModeRegister.IDLE;
    final size = const Size(800, 150);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FlounderHeader(state: state, size: size),
      ),
    ));

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('FlounderTimer renders', (WidgetTester tester) async {
    final state = ApplicationState();
    state.timer = 120;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FlounderTimer(
          state: state,
        ),
      ),
    ));

    // Should find the text '02:00'
    expect(find.text('02:00'), findsOneWidget);
  });

  testWidgets('FlounderStopwatch renders', (WidgetTester tester) async {
    final state = ApplicationState();
    state.profile = Profile(20, 5);
    state.timer = 1200 - 120; // Elapsed 120 seconds

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FlounderStopwatch(
          state: state,
        ),
      ),
    ));

    // Should find the text '02:00' because timer is initialized to 1200
    // and elapsed is 120. Elapsed time is 02:00.
    expect(find.text('02:00'), findsOneWidget);
  });
}
