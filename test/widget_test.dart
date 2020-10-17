import 'package:flutter_test/flutter_test.dart';

import 'package:word_trainer/main.dart';
import 'package:word_trainer/di.dart';

void main() {
  testWidgets('Home Widget renders', (WidgetTester tester) async {
    setup();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter has incremented.
    expect(find.text('Train'), findsNothing);
    expect(find.text('Words'), findsOneWidget);
  });
}
