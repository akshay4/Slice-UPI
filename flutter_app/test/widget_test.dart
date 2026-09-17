import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slicepay/main.dart';

void main() {
  testWidgets('SlicePay app loads calculator and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const SlicePayApp());
    expect(find.text('Slice'), findsOneWidget);
    expect(find.text('Passbook'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
  });
}
