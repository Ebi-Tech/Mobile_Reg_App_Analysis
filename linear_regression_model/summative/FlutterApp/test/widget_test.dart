import 'package:flutter_test/flutter_test.dart';
import 'package:student_score_predictor/main.dart';

void main() {
  testWidgets('App renders prediction screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentPredictorApp());
    expect(find.text('Student Score Predictor'), findsOneWidget);
  });
}
