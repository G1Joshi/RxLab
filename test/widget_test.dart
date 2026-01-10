import 'package:flutter_test/flutter_test.dart';
import 'package:rx_lab/app/app.dart';

void main() {
  testWidgets('Should find SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
