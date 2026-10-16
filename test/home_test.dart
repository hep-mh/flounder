import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flounder/home.dart';

void main() {
  testWidgets('Flounder App runs and shows home', (WidgetTester tester) async {
    await tester.pumpWidget(const Flounder());
    expect(find.byType(FlounderHome), findsOneWidget);
  });
}
