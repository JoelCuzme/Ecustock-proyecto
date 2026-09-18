import 'package:flutter_test/flutter_test.dart';

import 'package:ecustock/main.dart';

void main() {
  testWidgets('app loads with EcuStock branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('EcuStock'), findsWidgets);
  });
}
