import 'package:flutter_test/flutter_test.dart';
import 'package:jivaan_net_flutter/main.dart';

void main() {
  testWidgets('JivaanNet initial shell smoke test', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger initial frame.
    await tester.pumpWidget(const JivaanNetApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify key brand elements on the Home screen
    expect(find.text('JivaanNet'), findsOneWidget);
    expect(find.text('When towers fall, humanity connects'), findsOneWidget);
    expect(find.text('SOS'), findsOneWidget);
    expect(find.text('TAP FOR HELP'), findsOneWidget);
    expect(find.text('Pending SOS Requests'), findsOneWidget);

    // Verify bottom navigation tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Mesh'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap on the Requests tab
    await tester.tap(find.text('Requests'));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Requests screen header is visible
    expect(find.text('My SOS Requests'), findsOneWidget);

    // Tap on the Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Durgesh Sharma'), findsOneWidget);

    // Tap back on the Home tab
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Emergency Categories'), findsOneWidget);
  });
}
