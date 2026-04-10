import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_buddy/main.dart';

void main() {
  testWidgets('StudyBuddy splash screen shows expected text', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyBuddyApp());

    expect(find.text('StudyBuddy'), findsOneWidget);
    expect(find.text('Smart Task & Study Tracker'), findsOneWidget);

    // Advance time so the splash delay finishes and no pending timer remains.
    await tester.pump(const Duration(seconds: 3));

    // Dispose the app tree before test end.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
  });
}
