import 'package:flutter_test/flutter_test.dart';

import 'package:hp_express_inc/main.dart';

void main() {
  testWidgets('HP Express app loads the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HPExpressApp());

    expect(find.text('Join H&P Express Inc.'), findsOneWidget);
    expect(find.text('APPLY NOW'), findsWidgets);
  });
}
