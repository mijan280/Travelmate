import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/main.dart';

void main() {
  testWidgets('TravelMate smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelMateApp(isLoggedIn: false));

    // Verify that TravelMate title and Login button are rendered.
    expect(find.text('TravelMate'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });
}
