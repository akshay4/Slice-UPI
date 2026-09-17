import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slicepay/main.dart';

import 'package:flutter_slicepay/models/user_profile.dart';
import 'package:flutter_slicepay/services/app_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SlicePay app loads onboarding screen when not onboarded', (WidgetTester tester) async {
    await tester.pumpWidget(const SlicePayApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Enter your mobile number to get started'), findsOneWidget);
    expect(find.text('Register & Launch SlicePay'), findsOneWidget);
  });

  testWidgets('SlicePay app loads calculator and navigation when onboarded', (WidgetTester tester) async {
    await AppState.instance.completeOnboarding(
      name: 'Tester',
      phone: '9876543210',
    );
    await tester.pumpWidget(const SlicePayApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Slice'), findsOneWidget);
    expect(find.text('Pay'), findsWidgets);
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Passbook'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
  });
}
