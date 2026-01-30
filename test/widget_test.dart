// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ...existing code...
import 'package:flutter_test/flutter_test.dart';

import 'package:raheel/main.dart';

void main() {
  testWidgets('Splash screen shows رحيل text', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    // The splash screen should show the app name text
    expect(find.text('رحيل'), findsOneWidget);
  });
}
