import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_buddy/main.dart';

void main() {
  testWidgets('FocusNest splash screen shows expected text', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyBuddyApp());

    // Pump enough time for the async initialization to complete (500ms should be enough)
    await tester.pump(const Duration(milliseconds: 100));

    // Verify splash screen texts appear
    expect(find.text('FocusNest'), findsOneWidget);
    expect(find.text('Smart Task & Study Tracker'), findsOneWidget);

    // Close the app tree to clean up properly
    await tester.pumpWidget(const SizedBox());
  });
}
