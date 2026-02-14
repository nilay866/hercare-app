import 'package:flutter_test/flutter_test.dart';
import 'package:hercare_app/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HerCareApp());
    expect(find.text('HerCare'), findsOneWidget);
  });
}
