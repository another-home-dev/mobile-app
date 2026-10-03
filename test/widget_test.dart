import 'package:flutter_test/flutter_test.dart';

import 'package:another_home/main.dart';

void main() {
  testWidgets('app starts on the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Another Home'), findsOneWidget);
    expect(find.text('Your hostel, in your pocket'), findsOneWidget);

    // Let the splash screen timer and navigation transition complete
    await tester.pump(const Duration(seconds: 2));
  });
}
