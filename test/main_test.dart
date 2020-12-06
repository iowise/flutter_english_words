import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:word_trainer/main.dart';
import 'package:word_trainer/di.dart';

void main() {
  setUp(() {
    setup();
  });
  tearDown(() {
    GetIt.I.reset();
  });
  testWidgets('Home Widget renders', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify that our counter has incremented.
    expect(find.text('Train'), findsNothing);
    expect(find.text('Words'), findsOneWidget);
  });
}
