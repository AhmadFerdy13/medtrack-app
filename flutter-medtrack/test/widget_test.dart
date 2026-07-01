import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/main.dart';

void main() {
  testWidgets('MedTrack app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedTrackApp());
    // Splash screen should show
    expect(find.text('MedTrack'), findsOneWidget);
  });
}
