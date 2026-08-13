import 'package:flutter_test/flutter_test.dart';

import 'package:another_home/main.dart';

void main() {
  testWidgets('app starts on the login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ANOTHER HOME'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
