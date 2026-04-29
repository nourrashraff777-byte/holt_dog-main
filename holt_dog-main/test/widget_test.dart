import 'package:flutter_test/flutter_test.dart';
import 'package:holt_dog/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HoltDogApp());

    // Basic check that the app starts.
    expect(find.byType(HoltDogApp), findsOneWidget);
  });
}
