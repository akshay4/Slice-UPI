import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_slicepay/main.dart';

import 'package:flutter_slicepay/services/app_state.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SlicePay app loads splash screen and transitions to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const SlicePayApp());
    expect(find.text('SlicePay'), findsOneWidget);
    expect(find.text('AUTONOMOUS UPI CORE SWITCH'), findsOneWidget);

    // Fast-forward splash screen timer
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Enter your mobile number to get started'), findsOneWidget);
    expect(find.text('Register & Launch SlicePay'), findsOneWidget);
  });

  testWidgets('SlicePay app transitions to main navigation when onboarded', (WidgetTester tester) async {
    await AppState.instance.completeOnboarding(
      name: 'Tester',
      phone: '9876543210',
    );
    await tester.pumpWidget(const SlicePayApp());
    // Fast-forward splash screen timer
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Slice'), findsOneWidget);
    expect(find.text('Pay'), findsWidgets);
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Passbook'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
  });
}
